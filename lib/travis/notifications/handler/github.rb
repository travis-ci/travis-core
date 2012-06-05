module Travis
  module Notifications
    module Handler

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class Github < Webhook
        EVENTS = /build:finished/

        def notify(event, build, *args)
          add_comment(build) if build.request.pull_request?
        end

        protected

          def add_comment(build)
            url  = build.request.comments_url
            authenticated do
              GH.post(url, :body => comment(build))
            end
            info "Successfully commented on #{url}."
          rescue Faraday::Error::ClientError => e
            message = e.message
            message += ": #{e.response[:status]} #{e.response[:body]}" if e.response
            error "Could not comment on #{url} (#{message})."
          end

          def self.http_options
            super.merge(:token => Travis.config.github.token)
          end

          def http_options
            self.class.http_options
          end

          def authenticated(&block)
            GH.with(http_options, &block)
          end

          def comment(build)
            "This pull request [#{build.passed? ? 'passes' : 'fails' }](#{build_url(build)}) (merged #{build.request.head_commit[0..7]} into #{build.request.base_commit[0..7]})."
          end

          def build_url(build)
            "#{Travis.config.http_host}/#{build.repository.slug}/builds/#{build.id}"
          end
      end
    end
  end
end

