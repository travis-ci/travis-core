module Travis
  module Addons
    module StatesCache
      class EventHandler < Event::Handler
        EVENTS = /build:finished/

        def handle?
          !pull_request? && Travis::Features.feature_active?(:states_cache)
        end

        def handle
          branch = commit['branch']
          repository_id = build['repository_id']
          cache.write(repository_id, branch, data)
        end

        def cache
          Travis.states_cache
        end

        def data
          {
            'finished_at' => build['finished_at'],
            'state' => build['state']
          }
        end
      end
    end
  end
end
