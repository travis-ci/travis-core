require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Events
      class FindAll < Base
        def run
          result
        end

        def updated_at
          result.maximum(:updated_at)
        end

        private

          def result
            @result ||= repo.events
          end

          def repo
            service(:repositories, :find_one, params).run
          end
      end
    end
  end
end
