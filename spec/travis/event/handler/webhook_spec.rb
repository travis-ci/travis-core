require 'spec_helper'

describe Travis::Event::Handler::Webhook do
  let(:handler) { Travis::Event::Handler::Webhook.any_instance }
  let(:build)   { stub('build') }

  before do
    Travis.config.notifications = [:webhook]
    handler.stubs(:handle => true, :handle? => true)
  end

  describe 'subscription' do
    it 'build:started notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:finished', build)
    end
  end

  describe 'instrumentation' do
    it 'instruments with "notify.webhook.handler.event.travis"' do
      ActiveSupport::Notifications.expects(:instrument).with do |event, data|
        event == 'notify.webhook.handler.event.travis' && data[:target].is_a?(Travis::Event::Handler::Webhook)
      end
      Travis::Event.dispatch('build:finished', build)
    end

    it 'meters on "notify.webhook.handler.event.travis"' do
      Metriks.expects(:timer).with('notify.webhook.handler.event.travis').returns(stub('timer', :update => true))
      Travis::Event.dispatch('build:finished', build)
    end
  end
end

