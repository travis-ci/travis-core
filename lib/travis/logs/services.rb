module Travis
  module Logs
    module Services
      autoload :Append,    'travis/logs/services/append'
      autoload :Aggregate, 'travis/logs/services/aggregate'
      autoload :Receive,   'travis/logs/services/receive'

      class << self
        def register
          constants(false).each { |name| const_get(name) }
        end
      end
    end
  end
end


