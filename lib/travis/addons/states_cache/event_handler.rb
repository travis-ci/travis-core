module Travis
  module Addons
    module StatesCache
      class EventHandler < Event::Handler
        EVENTS = /build:finished/

        def handle?
          result = !pull_request? && Travis::Features.feature_active?(:states_cache)
          Travis.logger.info("[states-cache] Checking if event handler should be run for repo_id=#{repository_id} branch=#{branch}, result: #{result}")
          result
        end

        def handle
          Travis.logger.info("[states-cache] Running event handler for repo_id=#{repository_id} branch=#{branch}")
          cache.write(repository_id, branch, data)
        rescue Exception => e
          Travis.logger.error("[states-cache] An error occurred while trying to handle states cache update: #{e.message}\n#{e.backtrace}")
          raise
        end

        def cache
          Travis.states_cache
        end

        def repository_id
          build['repository_id']
        end

        def branch
          commit['branch']
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
