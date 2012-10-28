module Travis
  module Notification
    class Instrument
      module Services
        autoload :Github,   'travis/notification/instrument/services/github'
        autoload :Requests, 'travis/notification/instrument/services/requests'
      end
    end
  end
end

