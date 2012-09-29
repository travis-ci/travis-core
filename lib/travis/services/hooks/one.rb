module Travis
  module Services
    module Hooks
      class One < Base
        def run
          repository(params).service_hook
        end

        private

          def repository(params)
            current_user.repositories.administratable.find_by(params) || raise(ActiveRecord::RecordNotFound)
          end
      end
    end
  end
end
