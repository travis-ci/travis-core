require 'rake'
require 'rspec/core/rake_task'
require 'tasks/standalone_migrations'

load 'lib/tasks/heroku.rake'

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/**/*_spec.rb'
end

task :default => :spec


