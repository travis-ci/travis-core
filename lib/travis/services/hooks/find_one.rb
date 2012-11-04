module Travis
  module Services
    module Hooks
      class FindOne < Base
        def run
          current_user.service_hooks.first
        end
      end
    end
  end
end
