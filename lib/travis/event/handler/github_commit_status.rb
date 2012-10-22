module Travis
  module Event
    class Handler

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class GithubCommitStatus < Handler
        delegate :repository, :request, :to => :object

        API_VERSION = 'v2'
        EVENTS = /build:(started|finished)/

        attr_reader :payload, :params, :token

        def initialize(*)
          super
          @token = find_token
          if handle?
            @payload = Api.data(object, :for => 'event', :version => API_VERSION)
            @params  = { :url => url, :build_url => build_url, :token => token }
          end
        end

        def handle?
          token.present?
        end

        def handle
          Task.run(:github_commit_status, payload, params) if token
        end

        private

          def url
            "repos/#{slug}/statuses/#{sha}"
          end

          def build_url
            "#{Travis.config.http_host}/#{slug}/builds/#{object.id}"
          end

          def slug
            repository.slug
          end

          def sha
            request.pull_request? ? request.head_commit : request.commit.commit
          end

          def find_token
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
