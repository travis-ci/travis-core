module Travis
  module Services
    module Hooks
      class FindOne < Base
        def run
          repo.service_hook if repo
        end

        private

          def repo
            @repo ||= current_user.repositories.administratable.find_by(params)
          end
      end
    end
  end
end
