module Travis
  module Github
    module Services
      class SyncUser < Travis::Services::Base
        # Fetches the GitHub hook status for all repositories the user has
        # admin access to.
        class Hooks
          def initialize(user, force = false, gh = Github.authenticated(user))
            @user = user
            @force = force
            @gh = gh
          end

          def run
            { :synced => sync_hooks }
          end

          private

          def sync_hooks
            repositories.map do |repository|
              sync_hook(repository)
            end
          end

          def should_sync?(repository)
            @force || repository.last_sync.nil? || repository.last_sync < 24.hours.ago
          end

          def repositories
            @user.repositories.merge(Permission.where(admin: true))
          end

          def sync_hook(repository)
            return unless should_sync?(repository)

            repository.update_attributes!(active: hook_active?(repository), last_sync: Time.now)
          end

          def hook_active?(repository)
            hooks(repository)
              .select { |hook| hook['name'] == 'travis' && hook['domain'] == hook_domain }
              .any?   { |hook| hook['active'] }
          end

          def hook_domain
            Travis.config.service_hook_url || ''
          end

          def hooks(repository)
            @gh["/repositories/#{repository.github_id}/hooks"].to_a
          end
        end
      end
    end
  end
end
