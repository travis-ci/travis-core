require 'spec_helper'

describe Travis::Event::Handler::Email do
  include Travis::Testing::Stubs

  let(:handler) { Travis::Event::Handler::Email.any_instance }

  before do
    Travis::Event.stubs(:subscribers).returns [:email]
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
    it 'instruments with "travis.event.handler.email.notify"' do
      ActiveSupport::Notifications.stubs(:publish)
      ActiveSupport::Notifications.expects(:publish).with do |event, data|
        event =~ /travis.event.handler.email.notify/ && data[:target].is_a?(Travis::Event::Handler::Email)
      end
      Travis::Event.dispatch('build:finished', build)
    end

    it 'meters on "travis.event.handler.email.notify:completed"' do
      Metriks.expects(:timer).with('v1.travis.event.handler.email.notify:completed').returns(stub('timer', :update => true))
      Travis::Event.dispatch('build:finished', build)
    end
  end
end
