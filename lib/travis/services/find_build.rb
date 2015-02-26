require 'travis/services/base'

module Travis
  module Services
    class FindBuild < Base
      register :find_build

      def run(options = {})
        options[:exclude_config] ||= false
        preload(result(options)) if result(options)
      end

      def final?
        # TODO builds can be requeued, so finished builds are no more final
        # result.try(:finished?)
        false
      end

      def updated_at
        max = all_resources.max_by(&:updated_at)
        max.updated_at if max.respond_to?(:updated_at)
      end

      private

        def all_resources
          if result
            all = [result, result.commit, result.request, result.matrix.to_a, result.matrix.map(&:annotations)]
            all.flatten.find_all { |r| r.updated_at }
          else
            []
          end
        end

        def result(options = {})
          @result ||= load_result(options)
        end

        def load_result(options = {})
          columns = scope(:build).column_names
          columns -= %w(config) if options[:exclude_config]
          scope(:build).select(columns).find_by_id(params[:id]).tap do |res|
            res.config = {} if options[:exclude_config]
          end
        end

        def preload(build)
          ActiveRecord::Associations::Preloader.new(build, [:commit, :request, :matrix]).run
          ActiveRecord::Associations::Preloader.new(build.matrix, :log, :select => [:id, :job_id, :updated_at]).run
          ActiveRecord::Associations::Preloader.new(build.matrix, :annotations).run
          build
        end
    end
  end
end
