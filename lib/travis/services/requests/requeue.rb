# in travis-hub/handler/request:
#
# Services::Requests::Requeue.new(user, :build_id => 1, :token => current_user.token)

module Travis
  module Services
    module Requests
      class Requeue < Base
        extend Travis::Instrumentation

        def run
          requeue if request && accept?
        end
        instrument :run

        def accept?
          # TODO does this user have push access to this repo?
          true
        end

        private

          def requeue
            service(:requests, :receive, data).run
          end

          def data
            { :event_type => request.event_type, :payload => request.payload, :token => params[:token] }
          end

          def request
            build.request if build
          end

          def build
            @build ||= service(:builds, :one, :id => params[:build_id]).run
          end

          Travis::Notification::Instrument::Services::Requests::Requeue.attach_to(self)
      end
    end
  end
end
