# need to add this path for stand-alone migrations that use models
$: << 'lib/travis/model'

require 'rake'
require 'rspec/core/rake_task'
require 'tasks/standalone_migrations'
require 'travis'

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/**/*_spec.rb'
end

task :default => :spec
