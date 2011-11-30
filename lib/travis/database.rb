require 'active_record'
require 'erb'
require 'travis/support'

module Travis
  module Database
    class << self
      def connect
        ActiveRecord::Base.default_timezone = :utc
        ActiveRecord::Base.logger = Travis.logger
        ActiveRecord::Base.configurations = { env => Travis.config.database }
        ActiveRecord::Base.establish_connection(env)
      end

      def env
        Travis.config.env
      end
    end
  end
end
