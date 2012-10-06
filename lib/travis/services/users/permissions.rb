module Travis
  module Services
    module Users
      class Permissions < Base
        def run
          current_user.permissions.by_roles(params[:roles])
        end
      end
    end
  end
end
