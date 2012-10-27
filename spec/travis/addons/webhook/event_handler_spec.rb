require 'spec_helper'

describe Travis::Addons::Webhook::EventHandler do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Webhook::EventHandler }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  describe 'subscription' do
    let(:handler) { subject.any_instance }

    before :each do
      Travis::Event.stubs(:subscribers).returns [:webhook]
      handler.stubs(:handle => true, :handle? => true)
      Travis::Api.stubs(:data).returns(stub('data'))
    end

    it 'build:started notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:finished', build)
    end
  end

  describe 'handler' do
    let(:event) { 'build:finished' }

    before :each do
      build.stubs(:config => { :notifications => { :webhooks => 'http://webhook.com' } })
    end

    def notify
      subject.notify(event, build)
    end

    it 'triggers a task if the build is a push request' do
      build.stubs(:pull_request?).returns(false)
      Travis::Task.expects(:run).with(:webhook, payload, targets: ['http://webhook.com'], token: 'token')
      notify
    end

    it 'does not trigger a task if the build is a pull request' do
      build.stubs(:pull_request?).returns(true)
      Travis::Task.expects(:run).never
      notify
    end

    it 'triggers a task if webhooks are present' do
      build.stubs(:config => { :notifications => { :webhooks => 'http://webhook.com' } })
      Travis::Task.expects(:run).with(:webhook, payload, targets: ['http://webhook.com'], token: 'token')
      notify
    end

    it 'does not trigger a task if no webhooks are present' do
      build.stubs(:config => { :notifications => { :webhooks => [] } })
      Travis::Task.expects(:run).never
      notify
    end

    it 'triggers a task if specified by the config' do
      Travis::Event::Config.any_instance.stubs(:send_on_finished_for?).with(:webhooks).returns(false)
      Travis::Task.expects(:run).never
      notify
    end

    it 'does not trigger task if specified by the config' do
      Travis::Event::Config.any_instance.stubs(:send_on_finish?).with(:webhooks).returns(true)
      Travis::Task.expects(:run).with(:webhook, payload, targets: ['http://webhook.com'], token: 'token')
      notify
    end
  end

  describe :targets do
    let(:handler) { subject.new('build:finished', build, {}, payload) }

    it 'returns an array of urls when given a string' do
      webhooks = 'http://evome.fr/notifications'
      build.stubs(:config => { :notifications => { :webhooks => webhooks } })
      handler.targets.should == [webhooks]
    end

    it 'returns an array of urls when given an array' do
      webhooks = %w(http://evome.fr/notifications http://example.com)
      build.stubs(:config => { :notifications => { :webhooks => webhooks } })
      handler.targets.should == webhooks
    end

    it 'returns an array of multiple urls when given a comma separated string' do
      webhooks = 'http://evome.fr/notifications, http://example.com'
      build.stubs(:config => { :notifications => { :webhooks => webhooks } })
      handler.targets.should == webhooks.split(',').map(&:strip)
    end

    it 'returns an array of values if the build configuration specifies an array of urls within a config hash' do
      webhooks = { :urls => %w(http://evome.fr/notifications http://example.com), :on_success => 'change' }
      build.stubs(:config => { :notifications => { :webhooks => webhooks } })
      handler.targets.should == webhooks[:urls]
    end
  end

  # describe 'does not explode on invalid .travis.yml syntax' do
  #   it 'when :notifications contains an array' do
  #     # e.g. https://github.com/sieben/sieben.github.com/blob/05f09da13221e054ef2dafa1baf2fb4d9826ebb3/.travis.yml
  #     config.config[:notifications] = [{ :email => false }]
  #     lambda { config.webhooks }.should_not raise_error
  #   end
  # end

  # describe 'instrumentation' do
  #   let(:handler) { Travis::Event::Handler::Webhook.any_instance }

  #   before do
  #     Travis::Event.stubs(:subscribers).returns [:webhook]
  #     handler.stubs(:handle => true, :handle? => true)
  #   end

  #   it 'instruments with "travis.event.handler.webhook.notify"' do
  #     ActiveSupport::Notifications.stubs(:publish)
  #     ActiveSupport::Notifications.expects(:publish).with do |event, data|
  #       event =~ /travis.event.handler.webhook.notify/ && data[:target].is_a?(Travis::Event::Handler::Webhook)
  #     end
  #     Travis::Event.dispatch('build:finished', build)
  #   end

  #   it 'meters on "travis.event.handler.webhook.notify:completed"' do
  #     Metriks.expects(:timer).with('v1.travis.event.handler.webhook.notify:completed').returns(stub('timer', :update => true))
  #     Travis::Event.dispatch('build:finished', build)
  #   end
  # end
end
