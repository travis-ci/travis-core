require 'spec_helper'

describe Travis::Notifications::Handler::Campfire do
  let(:handler) { Travis::Notifications::Handler::Campfire.any_instance }
  let(:build)   { stub('build') }

  before do
    Travis.config.notifications = [:campfire]
  end

  describe 'subscription' do
    it 'build:started does not notify' do
      handler.expects(:call).never
      Travis::Notifications.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:call)
      Travis::Notifications.dispatch('build:finished', build)
    end
  end
end
