module Travis
  module Services
    class ReceiveRequest < Base
      class Instrument < Notification::Instrument
        def run_completed
          publish(
            :msg => "type=#{params[:event_type].inspect}",
            :type => params[:event_type],
            :accept? => target.accept?,
            :token => params[:token],
            :payload => params[:payload]
          )
        end

        def params
          target.params
        end
      end
    end
  end
end
