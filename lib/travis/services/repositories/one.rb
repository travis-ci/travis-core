module Travis
  module Services
    module Repositories
      class One < Base
        def run(options = {})
          result
        end

        def updated_at
          result.updated_at
        end

        private

          def result
            @result ||= scope(:repository).find_by(params)
          end
      end
    end
  end
end
