require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Events
      class FindAll < Base
        def run
          preload(result)
        end

        def updated_at
          result.maximum(:updated_at)
        end

        private

          def result
            @result ||= repo.events
          end

          def repo
            # service(:repositories, :find_one, params).run
            service(:repositories, :one, params).run
          end

          def preload(events)
            events.includes(:source)
          end
      end
    end
  end
end
