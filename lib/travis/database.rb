require 'active_record'
require 'erb'

module Travis
  module Database
    class << self
      attr_reader :options

      def connect(options = {})
        @options = options

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
