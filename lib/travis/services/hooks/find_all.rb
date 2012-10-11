module Travis
  module Services
    module Hooks
      class FindAll < Base
        def run
          current_user.service_hooks(params)
        end
      end
    end
  end
end
