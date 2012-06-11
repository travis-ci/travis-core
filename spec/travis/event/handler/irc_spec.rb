require 'spec_helper'

describe Travis::Event::Handler::Irc do
  include Travis::Testing::Stubs

  let(:handler) { Travis::Event::Handler::Irc.any_instance }

  before do
    Travis::Event.stubs(:subscribers).returns [:irc]
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
    it 'instruments with "travis.event.handler.irc.notify:call"' do
      ActiveSupport::Notifications.expects(:instrument).with do |event, data|
        event == 'travis.event.handler.irc.notify:call' && data[:target].is_a?(Travis::Event::Handler::Irc)
      end
      Travis::Event.dispatch('build:finished', build)
    end

    it 'meters on "travis.event.handler.irc.notify:call"' do
      Metriks.expects(:timer).with('travis.event.handler.irc.notify:call').returns(stub('timer', :update => true))
      Travis::Event.dispatch('build:finished', build)
    end
  end
end
