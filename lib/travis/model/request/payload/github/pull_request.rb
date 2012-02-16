require 'github'

class Request
  module Payload
    module Github
      class PullRequest < ::Github::ServiceHook::PullRequest
        include Base

        def reject?
          no_commit_change? || super
        end

        def attributes
          super.merge "comments_url" => comments_url
        end

        protected

          def no_commit_change?
            action != "opened" and action != "synchronize"
          end
      end
    end
  end
end
