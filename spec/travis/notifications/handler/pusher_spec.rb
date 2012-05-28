require 'spec_helper'
require 'support/active_record'
require 'support/mocks/pusher'

describe Travis::Notifications::Handler::Pusher do
  include Support::ActiveRecord

  let(:build)     { Factory.build(:build) }
  let(:configure) { Factory.build(:configure) }
  let(:test)      { Factory.build(:test) }
  let(:worker)    { Factory.build(:worker) }
  let(:handler)   { Travis::Notifications::Handler::Pusher.any_instance }


  before do
    Travis.config.notifications = [:pusher]
  end

  describe 'subscription' do
    it 'job:configure:created' do
      handler.expects(:call).never
      Travis::Notifications.dispatch('job:configure:created', configure)
    end

    it 'job:configure:finished' do
      handler.expects(:call).never
      Travis::Notifications.dispatch('job:configure:finished', configure)
    end

    it 'job:test:created' do
      handler.expects(:call)
      Travis::Notifications.dispatch('job:test:created', test)
    end

    it 'job:test:started' do
      handler.expects(:call)
      Travis::Notifications.dispatch('job:test:started', test)
    end

    it 'job:log' do
      handler.expects(:call)
      Travis::Notifications.dispatch('job:test:log', test)
    end

    it 'job:test:finished' do
      handler.expects(:call)
      Travis::Notifications.dispatch('job:test:finished', test)
    end

    it 'build:started' do
      handler.expects(:call)
      Travis::Notifications.dispatch('build:started', build)
    end

    it 'build:finished' do
      handler.expects(:call)
      Travis::Notifications.dispatch('build:finished', build)
    end

    it 'worker:started' do
      handler.expects(:call)
      Travis::Notifications.dispatch('worker:started', worker)
    end
  end
end
