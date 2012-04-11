class Request
  module Payload
    module Github
      class PullRequest < GenericEvent
        ACTIONS = %w[opened synchronize]
        def action
          data["action"]
        end

        def event
          @event ||= Travis::Github::PullRequest.new data["pull_request"]
        end

        def attributes
          super.merge "comments_url" => event._links["comments"]
        end

        def accept?
          ACTIONS.include? action
        end

        def commit
          event.merge_commit
        end
      end
    end
  end
end
