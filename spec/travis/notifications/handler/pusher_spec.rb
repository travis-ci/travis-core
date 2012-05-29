require 'spec_helper'

describe Travis::Notifications::Handler::Pusher do
  let(:object)    { stub('object') }
  let(:handler)   { Travis::Notifications::Handler::Pusher.any_instance }

  before do
    Travis.config.notifications = [:pusher]
  end

  describe 'subscription' do
    it 'job:configure:created' do
      handler.expects(:call).never
      Travis::Notifications.dispatch('job:configure:created', object)
    end

    it 'job:configure:finished' do
      handler.expects(:call).never
      Travis::Notifications.dispatch('job:configure:finished', object)
    end

    it 'job:test:created' do
      handler.expects(:call)
      Travis::Notifications.dispatch('job:test:created', object)
    end

    it 'job:test:started' do
      handler.expects(:call)
      Travis::Notifications.dispatch('job:test:started', object)
    end

    it 'job:log' do
      handler.expects(:call)
      Travis::Notifications.dispatch('job:test:log', object)
    end

    it 'job:test:finished' do
      handler.expects(:call)
      Travis::Notifications.dispatch('job:test:finished', object)
    end

    it 'build:started' do
      handler.expects(:call)
      Travis::Notifications.dispatch('build:started', object)
    end

    it 'build:finished' do
      handler.expects(:call)
      Travis::Notifications.dispatch('build:finished', object)
    end

    it 'worker:started' do
      handler.expects(:call)
      Travis::Notifications.dispatch('worker:started', object)
    end
  end
end
