require 'spec_helper'

describe Travis::Notifications::Handler::Webhook do
  let(:handler) { Travis::Notifications::Handler::Webhook.any_instance }
  let(:build)   { stub('build') }

  before do
    Travis.config.notifications = [:webhook]
  end

  describe 'subscription' do
    it 'build:started notifies' do
      handler.expects(:call)
      Travis::Notifications.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:call)
      Travis::Notifications.dispatch('build:finished', build)
    end
  end
end

