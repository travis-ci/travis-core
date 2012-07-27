module Travis
  module Api
    module V2
      module Http
        class Artifact
          attr_reader :artifact, :options

          def initialize(artifact, options = {})
            @artifact = artifact
            @options = options
          end

          def data
            {
              'artifact' => artifact_data(artifact),
            }
          end

          private

            def artifact_data(job)
              {
                'id' => artifact.id,
                'job_id' => artifact.job_id,
                'type' => artifact.class.name.demodulize,
                'body' => artifact.content
              }
            end
        end
      end
    end
  end
end

