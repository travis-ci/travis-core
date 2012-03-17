# Standalone migrations

require 'rubygems'
require 'bundler/setup'
require 'rails'
require 'active_record/railtie'

Bundler.require

app = Class.new(Rails::Application)
app.config.active_support.deprecation = :log
app.load_tasks

Rake::Task['environment'].enhance do
  app.initialize!
end
