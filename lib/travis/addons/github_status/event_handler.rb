module Travis
  module Addons
    module GithubStatus

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class EventHandler < Event::Handler
        API_VERSION = 'v2'
        EVENTS = /build:(started|finished)/

        def handle?
          token.present?
        end

        def handle
          Travis::Task.run(:github_status, payload, token: token)
        end

        private

          def token
            repository['admin_token']
          end

          Instruments::EventHandler.attach_to(self)
      end
    end
  end
end

