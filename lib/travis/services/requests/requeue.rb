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
          push_permission? && build.finished? && !jobs_unfinished?
        end

        private

          def push_permission?
            current_user.permission?(:push, :repository_id => request.repository_id)
          end

          def jobs_unfinished?
            Job.unfinished.where(:source_id => build.id, :source_type => 'Build').any?
          end

          def requeue
            service(:requests, :receive, data).run
          end

          def data
            { :event_type => request.event_type, :payload => request.payload, :token => params[:token] }
          end

          def request
            build && build.request
          end

          def build
            @build ||= service(:builds, :one, :id => params[:build_id]).run
          end

          Travis::Notification::Instrument::Services::Requests::Requeue.attach_to(self)
      end
    end
  end
end
