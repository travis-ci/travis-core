require 'spec_helper'

describe Travis::Notifications::Handler::Archive do
  let(:handler) { Travis::Notifications::Handler::Archive.any_instance }
  let(:build)   { stub('build') }

  before do
    Travis.config.notifications = [:archive]
  end

  describe 'subscription' do
    it 'build:started does not call' do
      handler.expects(:call).never
      Travis::Notifications.dispatch('build:started', build)
    end

    it 'build:finish calls' do
      handler.expects(:call)
      Travis::Notifications.dispatch('build:finished', build)
    end
  end
end
