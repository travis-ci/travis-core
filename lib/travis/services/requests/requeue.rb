module Travis
  module Services
    module Requests
      class Requeue < Base
        extend Travis::Instrumentation
        include ActiveModel::Validations

        def run
          requeue && nil if request && accept?
        end
        instrument :run

        def accept?
          push_permission? && requeueable?
        end

        def messages
          messages = []
          messages << { :notice => 'The build was successfully requeued.' } if accept?
          messages << { :error  => 'You do not seem to have push permissions.' } unless push_permission?
          messages << { :error  => 'This build currently can not be requeued.' } unless requeueable?
          messages
        end

        private

          def requeue
            request.start!
          end

          def push_permission?
            current_user.permission?(:push, :repository_id => request.repository_id)
          end

          def requeueable?
            defined?(@requeueable) ? @requeueable : @requeueable = request.requeueable?
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
