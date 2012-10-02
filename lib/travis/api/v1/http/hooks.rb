module Travis
  module Api
    module V1
      module Http
        class Hooks
          attr_reader :hooks, :options

          def initialize(hooks, options = {})
            @hooks = hooks
            @options = options
          end

          def data
            {
              'hooks' => hooks.map { |hook| hook_data(hook) },
            }
          end

          private

            def hook_data(hook)
              {
                'uid' => [hook.owner_name, hook.name].join(':'),
                'url' => "https://github.com/#{hook.owner_name}/#{hook.name}",
                'name' => hook.name,
                'owner_name' => hook.owner_name,
                'description' => hook.description,
                'active' => hook.active,
                'private' => hook.private
              }
            end
        end
      end
    end
  end
end
