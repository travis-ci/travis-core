module Travis
  module Event
    class Handler

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class GithubCommitStatus < Handler
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        def handle?
          object.pull_request?
        end

        def handle
          if token
            Task.run(:github_commit_status, payload, :url => url, :sha => sha, :build_url => build_url, :token => token)
          end
        end

        def url
          "https://api.github.com/repos/#{slug}/statuses/#{sha1}"
        end

        def build_url
          "#{Travis.config.http_host}/#{slug}/builds/#{object.id}"
        end

        def payload
          @payload ||= Api.data(object, :for => 'event', :version => API_VERSION)
        end

        def slug
          object.repository.slug
        end

        def sha
          object.request.head_commit
        end

        def token
          user ? user.github_oauth_token : nil
        end

        def user
          object.repository.permissions.find { |p| p.admin? }
        end

        Notification::Instrument::Event::Handler::GithubCommitStatus.attach_to(self)
      end
    end
  end
end
