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
            GH.post(url, :body => comment(build))
            info "Successfully commented on #{url}."
          rescue
            error "Could not comment on #{url}." # TODO add response.status and body
          end

          def comment(build)
            "This pull request was tested on [Travis CI](#{build_url(build)}) and has #{build.passed? ? 'passed' : 'failed' }."
          end

          def build_url(build)
            "#{Travis.config.http_host}/#{build.repository.slug}/builds/#{build.id}"
          end
      end
    end
  end
end

