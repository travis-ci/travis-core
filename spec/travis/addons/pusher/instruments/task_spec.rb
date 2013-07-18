require 'spec_helper'

describe Travis::Addons::Pusher::Instruments::Task do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::Pusher::Task }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  describe 'given a job:started event' do
    let(:payload) { Travis::Api.data(test, for: 'pusher', type: 'job/started') }
    let(:task)    { subject.new(payload, event: 'job:test:started') }

    it 'publishes a event' do
      event.should publish_instrumentation_event(
        event: 'travis.addons.pusher.task.run:completed',
        message: 'Travis::Addons::Pusher::Task#run:completed for #<Job id=1> (event: job:test:started, channels: common)',
      )
      event[:data].except(:payload).should == {
        # repository: 'svenfuchs/minimal', # TODO
        object_id: 1,
        object_type: 'Job',
        channels: ['common'],
        event: 'job:test:started',
        client_event: 'job:started'
      }
      event[:data][:payload].should_not be_nil
    end
  end

  describe 'given a build:finished event' do
    let(:payload) { Travis::Api.data(build, for: 'pusher', type: 'build/finished') }
    let(:task)    { subject.new(payload, event: 'build:finished') }

    it 'publishes a event' do
      event.should publish_instrumentation_event(
        event: 'travis.addons.pusher.task.run:completed',
        message: 'Travis::Addons::Pusher::Task#run:completed for #<Build id=1> (event: build:finished, channels: common)',
      )
      event[:data].except(:payload).should == {
        # repository: 'svenfuchs/minimal', # TODO
        object_id: 1,
        object_type: 'Build',
        channels: ['common'],
        event: 'build:finished',
        client_event: 'build:finished'
      }
      event[:data][:payload].should_not be_nil
    end
  end
end

