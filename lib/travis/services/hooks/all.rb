module Travis
  module Services
    module Hooks
      class All < Base
        def run
          current_user.service_hooks(params)
        end
      end
    end
  end
end
