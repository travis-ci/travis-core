module Travis
  module Notification
    class Instrument
      module Request
        class Factory < Instrument
          def request_completed
            publish(
              :msg => "#{target.class.name}#request type=#{target.type.inspect}",
              :type => target.type,
              :token => target.token,
              :accept? => target.accept?,
              :data => target.data
            )
          end
        end
      end
    end
  end
end

