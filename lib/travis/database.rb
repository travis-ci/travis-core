require 'active_record'
require 'erb'
require 'travis/support'

# Encapsulates setting up ActiveRecord and connecting to the database as
# required for travis-hub, which is a non-rails app.
module Travis
  module Database
    class << self
      def connect
        ActiveRecord::Base.default_timezone = :utc
        ActiveRecord::Base.logger = Travis.logger
        ActiveRecord::Base.configurations = { env => Travis.config.database }
        ActiveRecord::Base.establish_connection(Travis.env)
      end
    end
  end
end
