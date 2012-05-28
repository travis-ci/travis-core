require 'spec_helper'

describe Travis::Notifications::Handler::Email do
  let(:handler) { Travis::Notifications::Handler::Email.any_instance }
  let(:build)   { stub('build') }

  before do
    Travis.config.notifications = [:email]
  end

  it 'build:started does not call' do
    handler.expects(:call).never
    Travis::Notifications.dispatch('build:started', build)
  end

  it 'build:finish notifies' do
    handler.expects(:call)
    Travis::Notifications.dispatch('build:finished', build)
  end
end
