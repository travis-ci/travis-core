module Travis
  module Logs
    module Services
      class Receive < Travis::Services::Base
        register :logs_receive

        def run
          # publisher = Travis::Amqp::Publisher.jobs('logs')
          # publisher.publish(:data => data, :uuid => Travis.uuid)
        end
      end
    end
  end
end

