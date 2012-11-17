require 'travis/services/github_sync_user/organizations'
require 'travis/services/github_sync_user/repositories'
require 'travis/services/github_sync_user/repository'

module Travis
  module Services
    class GithubSyncUser < Base
      register :github_sync_user

      def run
        syncing do
          Organizations.new(user).run
          Repositories.new(user).run
        end
      end

      def user
        current_user
      end

      private

        def syncing
          user.update_column(:is_syncing, true) unless user.is_syncing?
          result = yield
          user.update_column(:synced_at, Time.now)
          result
        ensure
          user.update_column(:is_syncing, false)
        end
    end
  end
end

