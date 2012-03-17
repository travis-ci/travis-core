# need to add this path for stand-alone migrations that use models

require 'rspec/core/rake_task'
require File.expand_path('lib/migrations')
require 'travis'

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/**/*_spec.rb'
end

task :default => :spec
