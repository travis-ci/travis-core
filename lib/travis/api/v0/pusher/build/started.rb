module Travis
  module Api
    module V0
      module Pusher
        class Build
          class Started < Build
            autoload :Job, 'travis/api/v0/pusher/build/started/job'

            def data
              { 'build' => build_data, 'repository' => repository_data }
            end
          end
        end
      end
    end
  end
end

