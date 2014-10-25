require 'travis/github'
require 'travis/services/base'

module Travis
  module GitHub
    module Services
      class ValidateAdmin < Travis::Services::Base
        extend Travis::Instrumentation

        TIMEOUT = 2

        register :github_validate_admin

        MSG = {
          request_timed_out:        'timed out after %ds retrieving repository info for %s for %s',
          error_empty_repo_data:    'could not retrieve data for %s',
          error_fetching_repo_data: 'error retrieving repository info for %s for %s (status: %s): %s',
          admin_permission_removed: '%s no longer has admin access to %s',
          user_access_removed:      '%s no longer has any access to %s',
          token_invalid:            'token for %s no longer valid: removing github_oauth_token'
        }

        def run
          with_timeout(TIMEOUT) do
            return true if is_admin?
            admin_permissions_removed(permissions)
            false
          end
        rescue GH::Error => e
          handle_error(e)
        end

        private

          [:repo, :user].each do |key|
            define_method(key) { params[key] || raise("no #{key} passed") }
          end

          def is_admin?
            # TODO i'm not sure i understand this. are permissions only visible for admin users?
            permissions['admin']
          end

          def permissions
            @permissions ||= repo_data['permissions']
          end

          def repo_data
            Github.authenticated(user) do
              data = GH["repos/#{repo.slug}"]
              error MSG[:error_empty_repo_data] % repo.slug unless data
              data || { 'permissions' => {} }
            end
          end

          def admin_permissions_removed(permissions)
            info MSG[:admin_permission_removed] % [user.login, repo.slug]
            update_permissions(permissions)
          end

          # TODO does this not remove wayyy too many permissions? should be scoped to the repo, no?
          def repo_access_removed
            info MSG[:user_access_removed] % [user.login, repo.slug]
            update_permissions({})
          end

          def remove_github_oauth_token
            error MSG[:token_invalid] % [user.login]
            user.update_attributes!(github_oauth_token: '')
          end

          def update_permissions(permissions)
            user.update_attributes!(permissions: permissions)
          end

          def handle_error(e)
            case status = e.info[:response_status]
            when 401
              remove_github_oauth_token
            when 404
              repo_access_removed
            when Timeout::Error
            else
              msg = MSG[:error_fetching_repo_data] % [repo.slug, user.login, status, e.message]
              msg.split("\n").each { |line| error(line) }
            end
            false
          end

          def with_timeout(timeout, &block)
            Timeout.timeout(timeout, &block)
          rescue Timeout::Error => error
            error MSG[:request_timed_out] % [TIMEOUT, repo.slug, user.login]
            false
          end

          [:info, :warn, :error].each do |method|
            define_method(method) do |msg|
              Travis.logger.send(method, "[github-validate-admin] #{msg}")
            end
          end

          class Instrument < Notification::Instrument
            def run_completed
              publish(msg: "for #{target.repo.slug}: #{result ? result.login : 'no admin found'}", result: result.login)
            end
          end
          Instrument.attach_to(self)
      end
    end
  end
end
