module Travis
  module Github
    module Services
      class SyncUser < Travis::Services::Base
        autoload :Organizations, 'travis/github/services/sync_user/organizations'
        autoload :Repositories,  'travis/github/services/sync_user/repositories'
        autoload :Repository,    'travis/github/services/sync_user/repository'

        register :github_sync_user

        def run
          syncing do
            Organizations.new(user).run
            Repositories.new(user).run
          end
        end

        def user
          # TODO check that clients are only passing the id
          @user ||= current_user || User.find(params[:id])
        end

        private

          def syncing
            user.update_column(:is_syncing, true)
            result = yield
            user.update_column(:synced_at, Time.now)
            result
          ensure
            user.update_column(:is_syncing, false)
          end
      end
    end
  end
end
