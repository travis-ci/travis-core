module Travis
  module Addons
    module GithubStatus

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class EventHandler < Event::Handler
        API_VERSION = 'v2'
        EVENTS = /build:(started|finished)/

        def handle?
          admin_token.present?
        end

        def handle
          Travis::Addons::GithubStatus::Task.run(:github_status, payload, admin_token: admin_token)
        end

        private

          def admin_token
            admin.try(:github_oauth_token)
          rescue Travis::AdminMissing => error
            Travis.logger.error error.message
            nil
          end

          def admin
            @admin ||= Travis::Services.run(:github, :find_admin, repository: object.repository)
          end

          Instruments::EventHandler.attach_to(self)
      end
    end
  end
end

