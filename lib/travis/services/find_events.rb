module Travis
  module Services
    class FindEvents < Base
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
          @repo ||= run_service(:find_repo, params)
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
