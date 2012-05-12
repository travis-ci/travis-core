module Travis
  module Api
    module Http
      module V2
        class Branches
          include Formats

          attr_reader :repository

          def initialize(repository, options = {})
            @repository = repository
          end

          def data
            repository.last_finished_builds_by_branches.map do |build|
              Build.new(build, :include_branches => false).data
            end
          end
        end
      end
    end
  end
end
