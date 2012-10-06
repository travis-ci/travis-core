module Travis
  module Api
    module V2
      module Http
        class Permissions
          attr_reader :permissions, :options

          def initialize(permissions, options = {})
            @permissions = permissions
            @options = options
          end

          def data
            { 'permissions' => repo_ids }
          end

          private

            def repo_ids
              permissions.map { |permission| permission.repository_id }
            end
        end
      end
    end
  end
end
