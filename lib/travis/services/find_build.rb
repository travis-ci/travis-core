module Travis
  module Services
    class FindBuild < Base
      def run(options = {})
        preload(result) if result
      end

      def final?
        result.try(:finished?)
      end

      def updated_at
        max = all_resources.max_by(&:updated_at)
        max.updated_at if max.respond_to?(:updated_at)
      end

      private

        def all_resources
          if result
            all = [result, result.commit, result.request, result.matrix.to_a]
            all.flatten.find_all { |r| r.updated_at }
          else
            []
          end
        end

        def result
          @result ||= scope(:build).find_by_id(params[:id])
        end

        def preload(build)
          ActiveRecord::Associations::Preloader.new(build, [:commit, :request, :matrix]).run
          ActiveRecord::Associations::Preloader.new(build.matrix, :log, :select => [:id, :job_id, :updated_at]).run
          build
        end
    end
  end
end
