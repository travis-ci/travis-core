require 'travis/services/base'

module Travis
  module Services
    class FindEvents < Base
      register :find_events

      def run
        preload(result)
      end

      def updated_at
        result.maximum(:updated_at)
      end

      private

        def result
          @result ||= repo.events.recent
        end

        def repo
          @repo ||= Travis.run_service(:find_repo, params)
        end

        def preload(events)
          events.includes(:source)
        end

        def preload(events)
          events.includes(:source)
        end
    end
  end
end
