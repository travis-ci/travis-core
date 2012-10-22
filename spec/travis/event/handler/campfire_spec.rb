require 'spec_helper'

describe Travis::Event::Handler::Campfire do
  include Travis::Testing::Stubs

  let(:handler) { Travis::Event::Handler::Campfire.any_instance }

  before do
    Travis::Event.stubs(:subscribers).returns [:campfire]
    handler.stubs(:handle => true, :handle? => true)
    Broadcast.stubs(:by_repo).returns([broadcast])
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
    it 'instruments with notify.campfire.handler.event.travis' do
      ActiveSupport::Notifications.stubs(:publish)
      ActiveSupport::Notifications.expects(:publish).with do |event, data|
        event =~ /travis.event.handler.campfire.notify/ && data[:target].is_a?(Travis::Event::Handler::Campfire)
      end
      Travis::Event.dispatch('build:finished', build)
    end

    it 'meters on "travis.event.handler.campfire.notify:completed"' do
      Metriks.expects(:timer).with('v1.travis.event.handler.campfire.notify:completed').returns(stub('timer', :update => true))
      Travis::Event.dispatch('build:finished', build)
    end
  end
end
