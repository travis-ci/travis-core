module Travis
  module Api
    module V0
      module Pusher
        class Build
          class Finished < Build
            def data
              { 'build' => build_data, 'repository' => repository_data }
            end

            def build_data
              super.
                reject { |key, value| key == 'config' }.
                merge({ 'duration' => build.duration })
            end
          end
        end
      end
    end
  end
end


