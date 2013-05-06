ENV['RAILS_ENV'] = ENV['ENV'] = 'test'

RSpec.configure do |c|
  c.before(:each) { Time.now.utc.tap { | now| Time.stubs(:now).returns(now) } }
end

require 'support'

require 'travis'
require 'travis/support'
require 'travis/support/testing/webmock'
require 'travis/testing/matchers'

require 'gh'
require 'mocha'
require 'stringio'
require 'logger'
require 'patches/rspec_hash_diff'

Travis.logger = Logger.new(StringIO.new)
Travis.services = Travis::Services
Travis::Features.start

include Mocha::API

RSpec.configure do |c|
  c.mock_with :mocha
  c.alias_example_to :fit, :focused => true
  c.filter_run :focused => true
  c.run_all_when_everything_filtered = true
  # c.backtrace_clean_patterns.clear

  c.include Travis::Support::Testing::Webmock

  c.before :each do
    Travis::Features.enable_for_all(:global_env_in_config)
    Travis::Event.instance_variable_set(:@queues, nil)
    Travis::Event.instance_variable_set(:@subscriptions, nil)
    Travis::Event.stubs(:subscribers).returns []
    Travis.config.oauth2 ||= {}
    Travis.config.oauth2.scope = 'public_repo,user'
    Travis::Github.stubs(:scopes_for).returns(['public_repo', 'user'])
    GH.reset
  end
end

# this keeps Model.inspect from exploding which happens for
# expected method calls in tests that do not use a db connection
require 'active_record'
ActiveRecord::Base.class_eval do
  def self.inspect
    super
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
