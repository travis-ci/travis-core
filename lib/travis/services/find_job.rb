module Travis
  module Services
    class FindJob < Base
      register :find_job

      def run(options = {})
        preload(result) if result
      end

      def final?
        # TODO jobs can be requeued, so finished jobs are no more final
        # result.try(:finished?)
        false
      end

      def updated_at
        [result, result.annotations].flatten.map(&:updated_at).max if result
      end

      private

        def result
          @result ||= scope(:job).find_by_id(params[:id])
        rescue ActiveRecord::SubclassNotFound => e
          Travis.logger.warn "[services:find-job] #{e.message}"
          raise ActiveRecord::RecordNotFound
        end

        def preload(job)
          ActiveRecord::Associations::Preloader.new(job, :log).run
          ActiveRecord::Associations::Preloader.new(job, :commit).run
          ActiveRecord::Associations::Preloader.new(job, :annotations).run
          job
        end
    end
  end
end
