require 'faraday/error'
require 'travis/services/base'
require 'travis/services/find_admin/cache'
require 'travis/github/services/validate_admin'

module Travis
  module Services
    class FindAdmin < Base
      extend Travis::Instrumentation
      include Travis::Logging

      register :find_admin

      def run
        repo_missing! unless repo
        admin = cache.lookup { validate? ? find_valid_admin : repo.admins.first }
        admin ? admin : admin_not_found!
      end
      instrument :run

      def repo
        params[:repository]
      end

      private

        def cache
          Cache.new(repo, params)
        end

        def validate?
          params[:validate] && Travis::Features.enabled_for_all?(:allow_validate_admin)
        end

        def find_valid_admin
          repo.admins.detect { |user| run_service(:github_validate_admin, repo: repo, user: user) }
        end

        def repo_missing!
          error "[github-admin] repository is nil: #{params.inspect}"
          raise Travis::RepositoryMissing, "no repository given"
        end

        def admin_not_found!
          error "[github-admin] no admin available for #{repo.slug}"
          raise Travis::AdminMissing.new("no admin available for #{repo.slug}")
        end

        class Instrument < Notification::Instrument
          def run_completed
            publish(msg: "for #{target.repo.slug}: #{result.login}", result: result)
          end
        end
        Instrument.attach_to(self)
    end
  end
end
