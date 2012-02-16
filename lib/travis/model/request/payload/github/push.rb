require 'github'

class Request
  module Payload
    module Github
      class Push < ::Github::ServiceHook::Push
        include Base

        def reject?
          no_commit? || super
        end

        protected

          def no_commit?
            last_commit.nil? || last_commit.commit.blank?
          end
      end
    end
  end
end
