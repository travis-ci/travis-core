module Travis
  module Event
    class Handler

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class GithubCommitStatus < Handler
        delegate :repository, :request, :to => :object

        API_VERSION = 'v2'
        EVENTS = /build:(started|finished)/

        def handle?
          true
        end

        def handle
          Task.run(:github_commit_status, payload, :url => url, :build_url => build_url, :token => token) if token
        end

        def url
          "repos/#{slug}/statuses/#{sha}"
        end

        def build_url
          "#{Travis.config.http_host}/#{slug}/builds/#{object.id}"
        end

        def payload
          @payload ||= Api.data(object, :for => 'event', :version => API_VERSION)
        end

        def slug
          repository.slug
        end

        def sha
          request.pull_request? ? request.head_commit : request.commit.commit
        end

        def token
          repository.admin.try(:github_oauth_token)
        rescue Travis::AdminMissing => error
          error error.message
          nil
        end

        Notification::Instrument::Event::Handler::GithubCommitStatus.attach_to(self)
      end
    end
  end
end
