module Travis
  module Notification
    class Instrument
      module Services
        module Requests
          class Receive < Instrument
            def run_completed
              publish(
                :msg => "#{target.class.name}#run type=#{request.event_type.inspect}",
                :type => request.event_type,
                :token => request.token,
                :accept? => target.accept?,
                :payload => request.payload
              )
            end

            def request
              target.request
            end
          end

          class Requeue < Instrument
            def run_completed
              publish(
                :msg => "#{target.class.name}#run build_id=#{target.params[:build_id]} type=#{result.event_type.inspect}",
                :type => result.event_type,
                :build_id => target.params[:build_id],
                :accept? => target.accept?,
                :payload => result.payload
              )
            end
          end
        end
      end
    end
  end
end

