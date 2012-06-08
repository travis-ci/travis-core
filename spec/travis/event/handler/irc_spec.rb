require 'spec_helper'

describe Travis::Event::Handler::Irc do
  let(:handler) { Travis::Event::Handler::Irc.any_instance }
  let(:build) { stub('build') }

  before do
    Travis.config.notifications = [:irc]
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
    it 'instruments with "irc.handler.event.travis"' do
      ActiveSupport::Notifications.expects(:instrument).with do |event, data|
        event == 'irc.handler.event.travis' && data[:target].is_a?(Travis::Event::Handler::Irc)
      end
      Travis::Event.dispatch('build:finished', build)
    end

    it 'meters on "irc.handler.event.travis"' do
      Metriks.expects(:timer).with('irc.handler.event.travis').returns(stub('timer', :update => true))
      Travis::Event.dispatch('build:finished', build)
    end
  end
end
