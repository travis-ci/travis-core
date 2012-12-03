module Travis
  module Api
    module V2
      module Http
        class Repository
          include Formats

          attr_reader :repository, :options

          def initialize(repository, options = {})
            @repository = repository
            @options = options.symbolize_keys.slice(*::Build.matrix_keys_for(options))
          end

          def data
            {
              'repo' => repository_data(repository)
            }
          end

          private

            # TODO why does this not include the last build? (i.e. 'builds' => { last build here })
            def repository_data(repository)
              {
                'id' => repository.id,
                'slug' => repository.slug,
                'description' => repository.description,
                'last_build_id' => repository.last_build_id,
                'last_build_number' => repository.last_build_number,
                'last_build_state' => repository.last_build_state.to_s,
                'last_build_duration' => repository.last_build_duration,
                'last_build_language' => repository.last_build_language,
                'last_build_started_at' => format_date(repository.last_build_started_at),
                'last_build_finished_at' => format_date(repository.last_build_finished_at)
              }
            end
        end
      end
    end
  end
end

