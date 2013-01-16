module Travis
  module Services
    class ResetModel < Base
      extend Travis::Instrumentation

      register :reset_model

      def run
        reset if target && accept?
        true
      end
      instrument :run

      def accept?
        permission? && resetable?
      end

      def messages
        messages = []
        messages << { notice: "The #{type} was successfully restarted." } if accept?
        messages << { error:  'You do not seem to have sufficient permissions.' } unless permission?
        messages << { error:  "This #{type} currently can not be restarted." } unless resetable?
        messages
      end

      def type
        @type ||= params[:build_id] ? :build : :job
      end

      def id
        @id ||= params[:"#{type}_id"]
      end

      private

        def reset
          target.reset!(reset_matrix: type == :build)
        end

        def permission?
          current_user.permission?(required_role, repository_id: target.repository_id)
        end

        def resetable?
          defined?(@resetable) ? @resetable : @resetable = target.resetable?
        end

        def required_role
          Travis.config.roles.reset_model
        end

        def target
          @target ||= service(:"find_#{type}", id: id).run
        end

        class Instrument < Notification::Instrument
          def run_completed
            publish(
              msg: "build_id=#{target.id} #{target.accept? ? 'accepted' : 'not accepted'}",
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

