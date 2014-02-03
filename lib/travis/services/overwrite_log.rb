module Travis
  module Services
    class OverwriteLog < Base
      register :overwrite_log

      FORMAT = "Log removed by %s at %s Reason: %s"

      def run(params)
        return false unless job

        log = job.log
        log.content = FORMAT % [current_user.name, DateTime.now.iso8601, params[:reason]]
        log.archive_verified = false
        log.archived_at = nil
        log.save!
      end

      def log
        @log ||= job.log
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