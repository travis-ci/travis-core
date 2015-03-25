require 'active_support/core_ext/hash/except'
require 'travis/support/instrumentation'
require 'travis/services/base'
require 'travis/advisory_locks'

module Travis
  module Services
    class UpdateJob < Base
      extend Travis::Instrumentation

      register :update_job

      EVENT = [:receive, :start, :finish, :reset]

      def run
        if job.canceled? && event != :reset
          # job is canceled, so we ignore events other than reset
          # and we send cancel event to the worker, it may not get
          # the first one
          cancel_job_in_worker
        else
          Metriks.timer("update_job.#{event}").time do
            with_transactional_advisory_lock("build-#{job.source.id}") do
              job.send(:"#{event}!", data.except(:id))
            end
          end
        end
      end
      instrument :run

      def job
        @job ||= Job::Test.find(data[:id])
      end

      def data
        @data ||= begin
          data = params[:data].symbolize_keys
          # TODO remove once workers send the state
          data[:state] = { 0 => :passed, 1 => :failed }[data.delete(:result)] if data.key?(:result)
          data
        end
      end

      def event
        @event ||= EVENT.detect { |event| event == params[:event].try(:to_sym) } || raise_unknown_event
      end

      def raise_unknown_event
        raise ArgumentError, "Unknown event: #{params[:event]}, data: #{data}"
      end

      def cancel_job_in_worker
        publisher.publish(type: 'cancel_job', job_id: job.id, source: 'update_job_service')
      end

      def publisher
        Travis::Amqp::FanoutPublisher.new('worker.commands')
      end

      def with_transactional_advisory_lock(id)
        result = nil
        Travis::AdvisoryLocks.exclusive(id, 30) do
          # ActiveRecord::Base.connection.begin_db_transaction
          # ActiveRecord::Base.connection.execute('SET TRANSACTION ISOLATION LEVEL SERIALIZABLE')
          result = yield
          # ActiveRecord::Base.connection.commit_db_transaction
        end
        result
      rescue => e
        # ActiveRecord::Base.connection.rollback_db_transaction
        raise
      end

      class Instrument < Notification::Instrument
        def run_completed
          publish(
            msg: "event: #{target.event} for <Job id=#{target.data[:id]}> data=#{target.data.inspect}",
            job_id: target.data[:id],
            event: target.event,
            data: target.data
          )
        end
        alias run_received run_completed
      end
      Instrument.attach_to(self)
    end
  end
end

