module Travis
  module Logs
    module Services
      autoload :Append, 'travis/logs/services/append'

      class << self
        def register
          constants(false).each { |name| const_get(name) }
        end
      end
    end
  end
end


