require 'spec_helper'

describe Travis::Event::Handler::Github do
  include Travis::Testing::Stubs

  before do
    Travis::Event.stubs(:subscribers).returns [:github]
    handler.stubs(:handle => true, :handle? => true)
  end

  describe 'subscription' do
    let(:handler) { Travis::Event::Handler::Github.any_instance }

    it 'build:started does not notify' do
      handler.expects(:notify).never
      Travis::Event.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:finished', build)
    end
  end

  describe 'given the request is not a pull_request event' do
    let(:handler) { Travis::Event::Handler::Github.new('build:finished', build) }

    before :each do
      build.request.stubs(:pull_request? => false)
    end

    it 'does not handle the notification' do
      handler.expects(:handle).never
      handler.notify
    end
  end

  describe 'given the request is a pull_request event' do
    let(:handler) { Travis::Event::Handler::Github.new('build:finished', build) }

    before :each do
      build.request.stubs(:pull_request? => true)
    end

    it 'handles the notification' do
      handler.expects(:handle)
      handler.notify
    end
  end

  describe 'instrumentation' do
    let(:handler) { Travis::Event::Handler::Github.any_instance }

    it 'instruments with "travis.event.handler.github.notify:call"' do
      ActiveSupport::Notifications.expects(:instrument).with do |event, data|
        event == 'travis.event.handler.github.notify:call' && data[:target].is_a?(Travis::Event::Handler::Github)
      end
      Travis::Event.dispatch('build:finished', build)
    end

    it 'meters on "travis.event.handler.github.notify:call"' do
      Metriks.expects(:timer).with('travis.event.handler.github.notify:call').returns(stub('timer', :update => true))
      Travis::Event.dispatch('build:finished', build)
    end
  end
end
