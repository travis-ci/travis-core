require 'active_record'
require 'pg'
require 'logger'
require 'fileutils'
require 'database_cleaner'
require 'support/factories'

FileUtils.mkdir_p('log')

config = Travis.config.database.dup
config.merge!('adapter' => 'jdbcpostgresql', 'username' => ENV['USER']) if RUBY_PLATFORM == 'java'

ActiveRecord::Base.logger = Logger.new('log/test.db.log')
ActiveRecord::Base.configurations = { 'test' => config }
ActiveRecord::Base.establish_connection('test')

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean_with :truncation

module Support
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      before :each do
        DatabaseCleaner.clean
      end
    end
  end
end
