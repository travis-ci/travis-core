require 'spec_helper'

describe Travis::Event::Handler::Archive do
  include Travis::Testing::Stubs

  let(:handler) { Travis::Event::Handler::Archive.any_instance }

  before do
    Travis::Event.stubs(:subscribers).returns [:archive]
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
    it 'instruments with "travis.event.handler.archive.notify:call"' do
      # ActiveSupport::Notifications.expects(:instrument).with('travis.event.handler.archive.notify:call', anything)
      Travis::Event.dispatch('build:finished', build)
    end

    it 'meters on "travis.event.handler.archive.notify"' do
      Metriks.expects(:timer).with('travis.event.handler.archive.notify:call').returns(stub('timer', :update => true))
      Travis::Event.dispatch('build:finished', build)
    end
  end
end
