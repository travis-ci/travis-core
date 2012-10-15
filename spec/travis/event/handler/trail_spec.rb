require 'spec_helper'

describe Travis::Event::Handler::Trail do
  include Travis::Testing::Stubs

  let(:handler) { Travis::Event::Handler::Trail.any_instance }

  before do
    Travis::Event.stubs(:subscribers).returns [:trail]
  end

  describe 'does not persist an event record' do
    it 'job:log' do
      handler.expects(:notify).never
      Travis::Event.dispatch('job:test:log', test)
    end

    it 'worker:added' do
      handler.expects(:notify).never
      Travis::Event.dispatch('worker:added', worker)
    end
  end

  describe 'persists an event record' do
    it 'request:finished' do
      Event.expects(:create!).with(
        :source => request,
        :repository => request.repository,
        :event => 'request:finished',
        :data => { :result => :accepted }
      )
      Travis::Event.dispatch('request:finished', request)
    end

    it 'job:test:created' do
      Event.expects(:create!).with(
        :source => test,
        :repository => test.repository,
        :event => 'job:test:created',
        :data => { :result => 0 }
      )
      Travis::Event.dispatch('job:test:created', test)
    end

    it 'job:test:started' do
      Event.expects(:create!).with(
        :source => test,
        :repository => test.repository,
        :event => 'job:test:started',
        :data => { :result => 0 }
      )
      Travis::Event.dispatch('job:test:started', test)
    end

    it 'job:test:finished' do
      Event.expects(:create!).with(
        :source => test,
        :repository => test.repository,
        :event => 'job:test:finished',
        :data => { :result => 0 }
      )
      Travis::Event.dispatch('job:test:finished', test)
    end

    it 'build:started' do
      Event.expects(:create!).with(
        :source => build,
        :repository => build.repository,
        :event => 'build:started',
        :data => { :result => 0 }
      )
      Travis::Event.dispatch('build:started', build)
    end

    it 'build:finished' do
      Event.expects(:create!).with(
        :source => build,
        :repository => build.repository,
        :event => 'build:finished',
        :data => { :result => 0 }
      )
      Travis::Event.dispatch('build:finished', build)
    end
  end
end

