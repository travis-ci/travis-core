require 'active_support/concern'
require 'simple_states'

class Job
  class Test

    # A Job::Test goes through the following lifecycle:
    #
    #  * A newly created instance is in the `created` state.
    #  * When started it sets attributes from the payload and clears its log
    #    (relevant for re-started jobs).
    #  * When finished it sets attributes from the payload and adds tags.
    #  * On both events it notifies event handlers and then propagates the even
    #    to the build it belongs to.
    #  * It also notifies event handlers of the `log` event whenever something
    #    is appended to the log.
    module States
      extend ActiveSupport::Concern

      # TODO remove :finished once we've updated the state column
      FINISHED_STATES      = [:finished, :passed, :failed, :errored, :canceled]
      FINISHING_ATTRIBUTES = [:result, :finished_at] # TODO remove this, have a service instead

      included do
        include SimpleStates, Job::States, Travis::Event

        states :created, :queued, :started, :passed, :failed, :errored, :canceled

        event :start,  to: :started
        event :finish, to: :finished, after: :add_tags
        event :all, after: [:propagate, :notify]
      end

      def enqueue # TODO rename to queue and make it an event, simple_states should support that now
        update_attributes!(state: :queued, queued_at: Time.now.utc)
        notify(:queue)
      end

      def start(data = {})
        log.update_attributes!(content: '') # TODO this should be in a restart method, right?
        self.started_at = data[:started_at]
        self.worker = data[:worker]
      end

      def finish(data = {})
        data = data.symbolize_keys.slice(:state, *FINISHING_ATTRIBUTES)
        data.delete(:state) if data.key?(:result) # TODO legacy payload, remove once workers set :state
        data.each { |key, value| send(:"#{key}=", value) }
      end

      def finished?
        FINISHED_STATES.include?(state.to_sym)
      end

      def result=(result)
        Travis.logger.warn("[DEPRECATED] setting result #{result.inspect} to #{inspect}. Set :state instead.")
        self.state = map_legacy_result(result) || result
      end

      def append_log!(chars)
        notify(:log, _log: chars)
      end

      protected

        def extract_finishing_attributes(attributes)
          extract!(attributes, :state, *FINISHING_ATTRIBUTES)
        end

        LEGACY_RESULTS = { 0 => 'passed', 1 => 'failed' }

        def map_legacy_result(result)
          LEGACY_RESULTS[result.to_i] if result.to_s =~ /^[\d]+$/
        end
    end
  end
end
