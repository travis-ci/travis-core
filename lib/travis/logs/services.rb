module Travis
  module Logs
    module Services
      autoload :Append, 'travis/logs/services/append'

      class << self
        def register
          constants(false).each do |name|
            Travis.services.add(:"logs_#{name.to_s.underscore}", const_get(name))
          end
        end
      end
    end
  end
end


