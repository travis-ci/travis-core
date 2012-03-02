class Request
  module Payload
    module Github
      class Push < GenericEvent
        def event
          @event ||= Travis::Github::Push.new data
        end

        def reject?
          no_commit? or super
        end

        def commit
          event.commits.last
        end

        protected

          def no_commit?
            commit.nil? or commit.sha.blank?
          end
      end
    end
  end
end
