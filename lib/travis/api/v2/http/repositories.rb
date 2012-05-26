module Travis
  module Api
    module V2
      module Http
        class Repositories
          include Formats

          attr_reader :repositories, :options

          def initialize(repositories, options = {})
            @repositories = repositories
            @options = options
          end

          def data
            {
              'repositories' => repositories.map { |repos| Repository.new(repos, options).data['repository'] }
            }
          end
        end
      end
    end
  end
end
