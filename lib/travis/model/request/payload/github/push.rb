class Request
  module Payload
    module Github
      class Push < GenericEvent
        def pull_request
          @push ||= Travis::Github::Push.new data
        end

        def reject?
          no_commit? or super
        end

        protected

          def no_commit?
            commit.nil? or commit.sha.blank?
          end
      end
    end
  end
end
