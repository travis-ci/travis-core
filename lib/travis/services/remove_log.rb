module Travis
  module Services
    class RemoveLog < Base
      register :remove_log

      FORMAT = "Log removed by %s at %s"

      def run
        return nil unless job && can_remove?

        message = FORMAT % [current_user.name, DateTime.now.iso8601]
        if params[:reason]
          message << "\n\n#{params[:reason]}"
        end

        log.content = message
        log.archive_verified = false
        log.archived_at = nil
        log.save!
      end

      def log
        @log ||= job.log
      end

      def can_remove?
        authorized? && job.finished?
      end

      def authorized?
        current_user.permission?(:push, repository_id: job.repository.id)
      end

      private

      def job
        @job ||= scope(:job).find_by_id(params[:id])
      rescue ActiveRecord::SubclassNotFound => e
        Travis.logger.warn "[services:remove-log] #{e.message}"
        raise ActiveRecord::RecordNotFound
      end

    end
  end
end
