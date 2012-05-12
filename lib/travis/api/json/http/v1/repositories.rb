module Travis
  module Api
    module Json
      module Http
        module V1
          class Repositories
            include Formats

            attr_reader :repositories

            def initialize(repositories, options = {})
              @repositories = repositories
            end

            def data
              repositories.map { |repository| repository_data(repository) }
            end

            def repository_data(repository)
              {
                'id' => repository.id,
                'slug' => repository.slug,
                'description' => repository.description,
                'last_build_id' => repository.last_build_id,
                'last_build_number' => repository.last_build_number,
                'last_build_status' => repository.last_build_result,
                'last_build_result' => repository.last_build_result,
                'last_build_duration' => repository.last_build_duration,
                'last_build_language' => repository.last_build_language,
                'last_build_started_at' => format_date(repository.last_build_started_at),
                'last_build_finished_at' => format_date(repository.last_build_finished_at),
              }
            end
          end
        end
      end
    end
  end
end
