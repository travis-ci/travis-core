# Standalone migrations

require 'rubygems'
require 'bundler/setup'
require 'rails'
require 'active_record/railtie'

Bundler.require

Class.new(Rails::Application) do
  config.active_support.deprecation = :log
  initialize!
  load_tasks
end

