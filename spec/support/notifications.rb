module Support
  module Notifications
    extend ActiveSupport::Concern

    class Instrument < Travis::Notification::Instrument
      public :publish
    end

    def instrument(payload = {})
      status = payload.delete(:status) || :completed
      Instrument.new(payload[:message].to_s, status, payload)
    end

    def publish(payload = {})
      instrument.publish(payload)
    end

    included do
      before do
        @old_logger, @old_publishers, @old_uuid = Travis.logger, Travis::Notification.publishers, Travis.uuid
        Travis::Notification.publishers = [subject]
        Travis.uuid = nil
      end

      after do
        Travis.logger, Travis::Notification.publishers, Travis.uuid = @old_logger, @old_publishers, @old_uuid
      end
    end
  end
end
