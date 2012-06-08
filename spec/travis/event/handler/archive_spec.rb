require 'spec_helper'

describe Travis::Event::Handler::Archive do
  let(:handler) { Travis::Event::Handler::Archive.any_instance }
  let(:build)   { stub('build') }

  before do
    Travis.config.notifications = [:archive]
    handler.stubs(:handle)
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
    it 'instruments with "archive.handler.event.travis"' do
      ActiveSupport::Notifications.expects(:instrument).with do |event, data|
        event == 'archive.handler.event.travis' && data[:target].is_a?(Travis::Event::Handler::Archive)
      end
      Travis::Event.dispatch('build:finished', build)
    end

    it 'meters on "archive.handler.event.travis"' do
      Metriks.expects(:timer).with('archive.handler.event.travis').returns(stub('timer', :update => true))
      Travis::Event.dispatch('build:finished', build)
    end
  end
end
