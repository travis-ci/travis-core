require 'active_support/core_ext/object/blank'

module Travis
  module Event
    class Config
      class Hipchat < Config
        def send_on_finish?
          !build.pull_request? && rooms.present? && send_on_finish_for?(:hipchat)
        end

        def rooms
          @rooms ||= notification_values(:hipchat, :rooms).map { |room| room.split(',') }.flatten.map(&:strip).reject(&:blank?)
        end
      end
    end
  end
end
