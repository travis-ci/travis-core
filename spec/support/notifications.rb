module Support
  module Notifications
    extend ActiveSupport::Concern

    class Instrument < Travis::Notification::Instrument
      public :publish
    end

    def instrument(payload = {})
      Instrument.new(payload[:message].to_s, payload)
    end

    def publish(payload = {})
      instrument.publish(payload)
    end

    included do
      before do
        @old_logger, @old_publishers = Travis.logger, Travis::Notification.publishers
        Travis::Notification.publishers = [subject]
      end

      after do
        Travis.logger, Travis::Notification.publishers = @old_logger, @old_publishers
      end
    end
  end
end
