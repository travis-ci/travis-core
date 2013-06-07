require 'travis/mailer/user_mailer'

module Travis
  module Github
    module Services
      class SyncUser < Travis::Services::Base
        autoload :Organizations, 'travis/github/services/sync_user/organizations'
        autoload :Repositories,  'travis/github/services/sync_user/repositories'
        autoload :Repository,    'travis/github/services/sync_user/repository'
        autoload :UserInfo,      'travis/github/services/sync_user/user_info'

        register :github_sync_user

        def run
          new_user? do
            syncing do
              UserInfo.new(user).run
              Organizations.new(user).run
              Repositories.new(user).run
            end
          end
        end

        def user
          # TODO check that clients are only passing the id
          @user ||= current_user || User.find(params[:id])
        end

        def new_user?
          new_user = user.synced_at.nil?

          yield if block_given?

          if new_user and Travis.config.welcome_email
            send_welcome_email
          end
        end

        def send_welcome_email
          UserMailer.welcome_email(user).deliver
        end

        private

          def syncing
            unless user.github_oauth_token?
              logger.warn "user sync for #{user.login} (id:#{user.id}) was cancelled as the user doesn't have a token"
              return
            end
            user.update_column(:is_syncing, true)
            result = yield
            user.update_column(:synced_at, Time.now)
            result
          rescue GH::TokenInvalid => e
            logger.warn "user sync for #{user.login} (id:#{user.id}) failed as the token was invalid"
            user.update_column(:github_oauth_token, nil)
          ensure
            user.update_column(:is_syncing, false)
          end
      end
    end
  end
end
