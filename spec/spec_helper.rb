ENV['RAILS_ENV'] = ENV['ENV'] = 'test'

RSpec.configure do |c|
  c.before(:each) { Time.now.utc.tap { | now| Time.stubs(:now).returns(now) } }
end

require 'support/payloads'
require 'support/matchers'
require 'support/mocha'
require 'travis'
require 'travis/support'
require 'stringio'
require 'logger'
require 'patches/rspec_hash_diff'

Travis.logger = Logger.new(StringIO.new)

RSpec.configure do |config|
  config.after :each do
    Travis.instance_variable_set(:@config, nil)
    Travis::Notifications.instance_variable_set(:@queues, nil)
    Travis::Notifications.instance_variable_set(:@subscriptions, nil)
    Travis::Notifications::Handler::Pusher.send(:protected, :queue_for, :payload_for)
  end
  config.alias_example_to :fit, :focused => true
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
end

module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out.string
  ensure
    $stdout = STDOUT
  end
end
