require 'travis/services/base'

module Travis
  module Services
    class FindJob < Base
      register :find_job

      def run(options = {})
        options[:include_config] ||= false
        preload(result(options)) if result(options)
      end

      def final?
        # TODO jobs can be requeued, so finished jobs are no more final
        # result.try(:finished?)
        false
      end

      def updated_at
        [result].concat(result.annotations).map(&:updated_at).max if result
      end

      private

        def result(options = {})
          @result ||= load_result(options)
        rescue ActiveRecord::SubclassNotFound => e
          Travis.logger.warn "[services:find-job] #{e.message}"
          raise ActiveRecord::RecordNotFound
        end

        def load_result(options = {})
          columns = scope(:job).column_names
          columns -= %w(config) unless options[:include_config]
          scope(:job).select(columns).find_by_id(params[:id]).tap do |res|
            res.config = {} unless options[:include_config]
          end
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
