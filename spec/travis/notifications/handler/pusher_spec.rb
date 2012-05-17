require 'spec_helper'
require 'support/active_record'
require 'support/pusher'

describe Travis::Notifications::Handler::Pusher do
  include Support::ActiveRecord, Support::Pusher

  before do
    Travis.config.notifications = [:pusher]
    Travis::Notifications::Handler::Pusher.send(:public, :queue_for, :payload_for)
  end

  let(:receiver)  { Travis::Notifications::Handler::Pusher.new }
  let(:build)     { Factory(:build, :config => { :rvm => ['1.8.7', '1.9.2'] }) }
  let(:configure) { Factory(:configure) }
  let(:test)      { Factory(:test) }
  let(:worker)    { Factory(:worker) }

  # TODO these don't actually match the full behaviour, see Notifications::Handler::Pusher#client_event_for
  describe 'sends a message to pusher' do
    before :each do
      build
      pusher.messages.clear # because creating the build and job will publish messages, too
    end

    # it 'job:configure:created' do
    #   Travis::Notifications.dispatch('job:configure:created', configure)
    #   pusher.should have_message('job:created', configure)
    # end

    # it 'job:configure:finished' do
    #   Travis::Notifications.dispatch('job:configure:finished', configure)
    #   pusher.should have_message('job:finished', configure)
    # end

    it 'job:test:created' do
      Travis::Notifications.dispatch('job:test:created', test)
      pusher.should have_message('job:created', test)
    end

    it 'job:test:started' do
      Travis::Notifications.dispatch('job:test:started', test)
      pusher.should have_message('job:started', test)
    end

    it 'job:log' do
      Travis::Notifications.dispatch('job:test:log', test)
      pusher.should have_message('job:log', test)
    end

    it 'job:test:finished' do
      Travis::Notifications.dispatch('job:test:finished', test)
      pusher.should have_message('job:finished', test)
    end

    it 'build:started' do
      Travis::Notifications.dispatch('build:started', build)
      pusher.should have_message('build:started', build)
    end

    it 'build:finished' do
      Travis::Notifications.dispatch('build:finished', build)
      pusher.should have_message('build:finished', build)
    end

    it 'worker:started' do
      Travis::Notifications.dispatch('worker:started', worker)
      pusher.should have_message('worker:started', worker)
    end
  end

  describe 'payload_for returns the payload required for client side job events' do
    it 'job:created' do
      receiver.payload_for('job:created', test).should == Travis::Api::Pusher::Job::Created.new(test).data
    end

    it 'job:started' do
      receiver.payload_for('job:started', test).should == Travis::Api::Pusher::Job::Started.new(test).data
    end

    it 'job:log' do
      receiver.payload_for('job:log', test, 'log' => 'foo').should == Travis::Api::Pusher::Job::Log.new(test).data('log' => 'foo')
    end

    it 'job:finished' do
      receiver.payload_for('job:finished', test).should == Travis::Api::Pusher::Job::Finished.new(test).data
    end

    it 'build:started' do
      receiver.payload_for('build:started', build).should == Travis::Api::Pusher::Build::Started.new(build).data
    end

    it 'build:finished' do
      receiver.payload_for('build:finished', build).should == Travis::Api::Pusher::Build::Finished.new(build).data
     end

    it 'worker:started' do
      receiver.payload_for('worker:started', worker).should == Travis::Api::Pusher::Worker.new(worker).data
    end
  end

  describe 'queue_for' do
    it 'returns "common" for the event "job:created"' do
      receiver.queue_for('job:created', test).should == 'common'
    end

    it 'returns "common" for the event "job:started"' do
      receiver.queue_for('job:started', test).should == 'common'
    end

    it 'returns "job-1" for the event "job:log"' do
      receiver.queue_for('job:log', test).should == "job-#{test.id}"
    end

    it 'returns "common" for the event "job:finished"' do
      receiver.queue_for('job:finished', test).should == 'common'
    end

    it 'returns "common" for the event "build:started"' do
      receiver.queue_for('build:started', build).should == 'common'
    end

    it 'returns "common" for the event "build:finished"' do
      receiver.queue_for('build:finished', build).should == 'common'
    end

    it 'returns "common" for the event "worker:started"' do
      receiver.queue_for('worker:created', build).should == 'common'
    end
  end
end

