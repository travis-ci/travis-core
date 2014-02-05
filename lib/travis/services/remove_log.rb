module Travis
  module Services
    class RemoveLog < Base
      extend Travis::Instrumentation

      register :remove_log

      FORMAT = "Log removed by %s at %s"

      def run
        return nil unless job

        unless authorized?
          return { error: { message: "Unauthorized" } }
        end

        unless job.finished?
          return { error: { message: "<Job id=#{job.id}> is not finished" } }
        end

        message = FORMAT % [current_user.name, DateTime.now.iso8601]
        if params[:reason]
          message << "\n\n#{params[:reason]}"
        end

        log.content = message
        log.archive_verified = false
        log.archived_at = nil
        log.save! && log
      end

      instrument :run

      def log
        @log ||= job.log
      end

      def can_remove?
        authorized? && job.finished?
      end

      def authorized?
        current_user && current_user.permission?(:push, repository_id: job.repository.id)
      end

      def job
        @job ||= scope(:job).find_by_id(params[:id])
      rescue ActiveRecord::SubclassNotFound => e
        Travis.logger.warn "[services:remove-log] #{e.message}"
        raise ActiveRecord::RecordNotFound
      end

      class Instrument < Notification::Instrument
        def run_completed
          publish(
            :msg => "for <Job id=#{target.job.id}> (#{target.current_user.login})",
            :result => result
          )
        end
      end
      Instrument.attach_to(self)
    end
  end
end
