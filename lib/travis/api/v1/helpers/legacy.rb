module Travis
  module Api
    module V1
      module Helpers
        module Legacy
          def legacy_repository_last_build_result(repository)
            repository.last_build_state.try(:to_sym) == :passed ? 0 : 1
          end

          def legacy_build_state(build)
            build.finished? ? 'finished' : build.state.to_s
          end

          def legacy_build_result(build)
            build.state.try(:to_sym) == :passed ? 0 : 1
          end

          def legacy_job_state(job)
            job.finished? ? 'finished' : job.state.to_s
          end

          def legacy_job_result(job)
            job.state.try(:to_sym) == :passed ? 0 : 1
          end
        end
      end
    end
  end
end
