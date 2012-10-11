require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Builds
      class One < Base
        def run(options = {})
          preload(result) if result
        end

        def final?
          result.try(:finished?)
        end

        def updated_at
          result.try(:updated_at)
        end

        private

          def result
            @result ||= scope(:build).find_by_id(params[:id])
          end

          def preload(build)
            ActiveRecord::Associations::Preloader.new(build, [:commit, :request, :matrix]).run
            ActiveRecord::Associations::Preloader.new(build.matrix, :log, :select => [:id, :job_id]).run
            build
          end
      end
    end
  end
end
