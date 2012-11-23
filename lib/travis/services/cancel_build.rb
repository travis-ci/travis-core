module Travis
  module Services
    class CancelBuild < Base
      extend Travis::Instrumentation

      register :cancel_build

      def run
        cancel if can_cancel?
      end
      instrument :run

      def messages
        messages = []
        messages << { :notice => 'The build was successfully cancelled.' } if can_cancel?
        messages << { :error  => 'You are not authorized to cancel this build.' } unless authorized?
        messages << { :error  => "The build could not be cancelled." } unless build.cancelable?
        messages
      end

      def cancel
        build.cancel!
      end

      def can_cancel?
        authorized? && build.cancelable?
      end

      def authorized?
        current_user.permission?(:push, :repository_id => build.repository_id)
      end

      def build
        @build ||= run_service(:find_build, params)
      end

      class Instrument < Notification::Instrument
        def run_completed
          publish(
            :msg => "for <Build id=#{target.build.id}> (#{target.current_user.login})",
            :result => result
          )
        end
      end
      Instrument.attach_to(self)
    end
  end
end
