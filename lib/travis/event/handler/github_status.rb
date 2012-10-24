module Travis
  module Event
    class Handler

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class GithubStatus < Handler
        API_VERSION = 'v2'
        EVENTS = /build:(started|finished)/

        def handle?
          token.present?
        end

        def handle
          Task.run(:github_status, payload, token: token)
        end

        private

          def token
            repository['admin_token']
          end

          Notification::Instrument::Event::Handler::GithubStatus.attach_to(self)
      end
    end
  end
end
