ENV['RAILS_ENV'] = ENV['ENV'] = 'test'

RSpec.configure do |c|
  c.before(:each) { Time.now.utc.tap { | now| Time.stubs(:now).returns(now) } }
end

require 'gh'
require 'support/payloads'
require 'support/matchers'
require 'support/mocha'

require 'travis'
require 'travis/support'
require 'travis/support/testing/webmock'

require 'stringio'
require 'logger'
require 'patches/rspec_hash_diff'

Travis.logger = Logger.new(StringIO.new)

RSpec.configure do |c|
  c.alias_example_to :fit, :focused => true
  c.filter_run :focused => true
  c.run_all_when_everything_filtered = true
  # c.backtrace_clean_patterns.clear

  c.include Travis::Support::Testing::Webmock

  c.before :each do
    GH.reset
  end

  c.after :each do
    Travis.instance_variable_set(:@config, nil)
    Travis::Notifications.instance_variable_set(:@queues, nil)
    Travis::Notifications.instance_variable_set(:@subscriptions, nil)
    Travis::Notifications::Handler::Pusher.send(:protected, :queue_for, :payload_for)
  end
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
