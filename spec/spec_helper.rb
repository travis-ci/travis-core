ENV['RAILS_ENV'] = ENV['ENV'] = 'test'

RSpec.configure do |c|
  c.mock_with :mocha
  c.before(:each) { Time.now.utc.tap { | now| Time.stubs(:now).returns(now) } }
end

require 'support/payloads'
require 'support/matchers'

require 'travis'
require 'travis/support'
require 'stringio'
require 'logger'
require 'mocha'
require 'patches/rspec_hash_diff'

include Mocha::API

Travis.logger = Logger.new(StringIO.new)

RSpec.configure do |c|
  c.after :each do
    Travis.config.notifications.clear
    Travis::Notifications.instance_variable_set(:@subscriptions, nil)
    Travis::Notifications::Pusher.send(:protected, :queue_for, :payload_for)
  end
end
