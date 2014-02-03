module Travis
  module Services
    class OverwriteLog < Base
      register :overwrite_log

      FORMAT = "Log removed by %s at %s\n%s"

      def run(params)
        return nil unless job

        log = job.log
        log.content = FORMAT % [current_user.name, DateTime.now.iso8601, params[:reason]]
        log.archive_verified = false
        log.archived_at = nil
        log.save!
      end

      def log
        @log ||= job.log
      end

      def can_overwrite?
        authorized? && job.finished?
      end

      def authorized?
        current_user.permission?(:push, job.respository_id)
      end

      private

      def job
        @job ||= scope(:job).find_by_id(params[:id])
      rescue ActiveRecord::SubclassNotFound => e
        Travis.logger.warn "[services:overwrite-log] #{e.message}"
        raise ActiveRecord::RecordNotFound
      end

    end
  end
end
