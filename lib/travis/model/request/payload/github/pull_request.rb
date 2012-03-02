class Request
  module Payload
    module Github
      class PullRequest < GenericEvent
        def action
          data["action"]
        end

        def event
          @event ||= Travis::Github::PullRequest.new data["pull_request"]
        end

        def attributes
          super.merge "comments_url" => pull_request.links["comments"]
        end

        def reject?
          no_commit_change? or super
        end

        def commit
          event.merge_commit
        end

        private

          def no_commit_change?
            action != "opened" and action != "synchronize"
          end
      end
    end
  end
end
