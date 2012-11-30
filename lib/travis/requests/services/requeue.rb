module Travis
  module Requests
    module Services
      class Requeue < Travis::Services::Base
        extend Travis::Instrumentation

        register :requeue_request

        def run
          requeue if target && accept?
        end
        instrument :run

        def accept?
          permission? && requeueable?
        end

        def messages
          messages = []
          messages << { notice: "The #{type} was successfully requeued." } if accept?
          messages << { error:  'You do not seem to have sufficient permissions.' } unless permission?
          messages << { error:  "This #{type} currently can not be requeued." } unless requeueable?
          messages
        end

        def type
          @type ||= params[:build_id] ? :build : :job
        end

        def id
          @id ||= params[:"#{type}_id"]
        end

        private

          def requeue
            target.requeue
            true
          end

          def permission?
            current_user.permission?(required_role, repository_id: target.repository_id)
          end

          def requeueable?
            defined?(@requeueable) ? @requeueable : @requeueable = target.requeueable?
          end

          def required_role
            Travis.config.roles.requeue_request
          end

          def target
            @target ||= service(:"find_#{type}", id: id).run
          end

          class Instrument < Notification::Instrument
            def run_completed
              publish(
                msg: "build_id=#{target.id} #{result ? 'accepted' : 'not accepted'}",
                type: target.type,
                id: target.id,
                accept?: target.accept?
              )
            end
          end
          Instrument.attach_to(self)
      end
    end
  end
end
