require 'faraday/error'
require 'travis/services/base'

# TODO extract github specific stuff to a separate service

module Travis
  module Services
    class FindAdmin < Base
      extend Travis::Instrumentation
      include Travis::Logging

      register :find_admin
      NUM_CANDIDATES = 15

      def run
        if repository
          admin
        else
          error "[github-admin] repository is nil: #{params.inspect}"
          raise Travis::RepositoryMissing, "no repository given"
        end
      end
      instrument :run

      def repository
        params[:repository]
      end

      private

        def candidates
          User.with_github_token.with_permissions(:repository_id => repository.id, :admin => true).first(NUM_CANDIDATES)
        end

        def admin
          admin = candidates.detect do |candidate|
            is_valid? candidate
          end
          admin || raise_admin_missing
        end

        def is_valid?(admin)
          Timeout.timeout(2) do
            data = Github.authenticated(admin) { repository_data }
            if data['permissions'] && data['permissions']['admin']
              true
            else
              revoke_admin_rights admin
              false
            end
          end
        rescue Timeout::Error => error
          handle_error(admin, error)
          false
        rescue GH::Error => error
          handle_error(admin, error)
          false
        end

        def handle_error(user, error)
          status = error.info[:response_status]
          case status
          when 401
            error "[github-admin] token for #{user.login} no longer valid"
            user.update_attributes!(:github_oauth_token => "")
          when 404
            revoke_admin_rights user
          else
            error "[github-admin] error retrieving repository info for #{repository.slug} for #{user.login}: #{error.message}"
          end
        end

        # TODO should this not be memoized?
        def repository_data
          data = GH["repos/#{repository.slug}"]
          info "[github-admin] could not retrieve data for #{repository.slug}" unless data
          data || { 'permissions' => {} }
        end

        def raise_admin_missing
          raise Travis::AdminMissing.new("no admin available for #{repository.slug}")
        end

        def revoke_admin_rights(user)
          info "[github-admin] #{user.login} no longer has admin access to #{repository.slug}"

          Permission.where(user_id: user.id, repository_id: repository.id).update_all(admin: false)
        end

        class Instrument < Notification::Instrument
          def run_completed
            publish(
              msg: "for #{target.repository.slug}: #{result.login}",
              result: result
            )
          end
        end
        Instrument.attach_to(self)
    end
  end
end
