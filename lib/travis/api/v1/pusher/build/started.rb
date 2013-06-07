module Travis
  module Api
    module V1
      module Pusher
        class Build
          class Started < Build
            autoload :Job, 'travis/api/v1/pusher/build/started/job'

            include Helpers::Legacy

            def data
              { 'build' => build_data, 'repository' => repository_data }
            end
          end
        end
      end
    end
  end
end

