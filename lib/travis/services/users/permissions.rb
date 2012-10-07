module Travis
  module Services
    module Users
      class Permissions < Base
        def run
          scope = current_user.permissions
          scope = scope.by_roles(params[:roles].to_s.split(',')) if params[:roles]
          scope
        end
      end
    end
  end
end
