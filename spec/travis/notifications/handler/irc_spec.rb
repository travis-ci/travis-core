require 'spec_helper'

describe Travis::Notifications::Handler::Irc do
  let(:build) { stub('build') }

  before do
    Travis.config.notifications = [:irc]
  end

  describe 'subscription' do
    let(:handler) { Travis::Notifications::Handler::Irc.any_instance }

    it 'build:started does not call' do
      handler.expects(:call).never
      Travis::Notifications.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:call)
      Travis::Notifications.dispatch('build:finished', build)
    end
  end
end
