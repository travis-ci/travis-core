module Travis
  module Addons
    module GithubStatus

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class EventHandler < Event::Handler
        API_VERSION = 'v2'
        EVENTS = /build:(created|queued|started|finished)/

        def handle?
          token.present?
        end

        def handle
          Travis::Addons::GithubStatus::Task.run(:github_status, payload, token: token)
        end

        private

          def token
            admin.try(:github_oauth_token)
          rescue Travis::AdminMissing => error
            Travis.logger.error error.message
            nil
          end

          def admin
            @admin ||= Travis.run_service(:find_admin, repository: object.repository)
          end

          Instruments::EventHandler.attach_to(self)
      end
    end
  end
end

