require 'spec_helper'

describe Travis::Event::Handler::Email do
  let(:handler) { Travis::Event::Handler::Email.any_instance }
  let(:build)   { stub('build') }

  before do
    Travis.config.notifications = [:email]
    handler.stubs(:handle => true, :handle? => true)
  end

  describe 'subscription' do
    it 'build:started does not notify' do
      handler.expects(:notify).never
      Travis::Event.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:finished', build)
    end
  end

  describe 'instrumentation' do
    it 'instruments with "email.handler.event.travis"' do
      ActiveSupport::Notifications.expects(:instrument).with do |event, data|
        event == 'email.handler.event.travis' && data[:target].is_a?(Travis::Event::Handler::Email)
      end
      Travis::Event.dispatch('build:finished', build)
    end

    it 'meters on "email.handler.event.travis"' do
      Metriks.expects(:timer).with('email.handler.event.travis').returns(stub('timer', :update => true))
      Travis::Event.dispatch('build:finished', build)
    end
  end
end
