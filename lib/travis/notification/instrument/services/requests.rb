module Travis
  module Notification
    class Instrument
      module Services
        module Requests
          class Receive < Instrument
            def run_completed
              publish(
                :msg => "#{target.class.name}#run type=#{params[:event_type].inspect}",
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

          class Requeue < Instrument
            def run_completed
              publish(
                :msg => "#{target.class.name}#run build_id=#{target.params[:build_id]} #{result ? 'accepted' : 'not accepted'}",
                :build_id => target.params[:build_id],
                :accept? => target.accept?
              )
            end
          end
        end
      end
    end
  end
end
