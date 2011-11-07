require 'active_record'
require 'pg'
require 'logger'
require 'fileutils'
require 'database_cleaner'
require 'support/factories'

FileUtils.mkdir_p('log')

config = if RUBY_PLATFORM == 'java'
  { 'adapter' => 'jdbcpostgresql', 'database' => 'travis_test', 'username' => ENV['USER'], 'encoding' => 'unicode' }
else
  { 'adapter' => 'postgresql', 'database' => 'travis_test', 'encoding' => 'unicode' }
end

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



