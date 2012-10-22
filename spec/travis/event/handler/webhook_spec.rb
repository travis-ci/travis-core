require 'spec_helper'

describe Travis::Event::Handler::Webhook do
  include Travis::Testing::Stubs

  describe 'subscription' do
    let(:handler) { Travis::Event::Handler::Webhook.any_instance }

    before do
      Travis::Event.stubs(:subscribers).returns [:webhook]
      handler.stubs(:handle => true, :handle? => true)
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

  describe 'payload' do
    let(:handler) { Travis::Event::Handler::Webhook.new('build:finished', build) }

    it 'includes job logs to the payload if defined by the config' do
      build.config[:notifications] = { :webhooks => ['http://webhook.com'], :include_logs => true }
      handler.payload['matrix'].first['log'].should_not be_nil
    end

    it 'does not include job logs to the payload if defined by the config' do
      build.config[:notifications] = { :webhooks => ['http://webhook.com'], :include_logs => false }
      handler.payload['matrix'].first['log'].should be_nil
    end
  end

  describe 'instrumentation' do
    let(:handler) { Travis::Event::Handler::Webhook.any_instance }

    before do
      Travis::Event.stubs(:subscribers).returns [:webhook]
      handler.stubs(:handle => true, :handle? => true)
    end

    it 'instruments with "travis.event.handler.webhook.notify"' do
      ActiveSupport::Notifications.stubs(:publish)
      ActiveSupport::Notifications.expects(:publish).with do |event, data|
        event =~ /travis.event.handler.webhook.notify/ && data[:target].is_a?(Travis::Event::Handler::Webhook)
      end
      Travis::Event.dispatch('build:finished', build)
    end

    it 'meters on "travis.event.handler.webhook.notify:completed"' do
      Metriks.expects(:timer).with('v1.travis.event.handler.webhook.notify:completed').returns(stub('timer', :update => true))
      Travis::Event.dispatch('build:finished', build)
    end
  end
end
