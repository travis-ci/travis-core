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
    let(:payload) { Travis::Api.data(test, :for => 'pusher', :type => 'job/started', :version => 'v1') }
    let(:task)    { subject.new(payload, :event => 'job:test:started') }

    it 'publishes a payload' do
      event.except(:payload).should == {
        :message => "travis.addons.pusher.task.run:completed",
        :uuid => Travis.uuid
      }
      event[:payload].except(:payload).should == {
        :msg => 'Travis::Addons::Pusher::Task#run for #<Job id=1> (channels: common)',
        # :repository => 'svenfuchs/minimal', # TODO
        :object_id => 1,
        :object_type => 'Job',
        :channels => ['common'],
        :event => 'job:test:started',
        :client_event => 'job:started'
      }
      event[:payload][:payload].should_not be_nil
    end
  end

  describe 'given a build:finished event' do
    let(:payload) { Travis::Api.data(build, :for => 'pusher', :type => 'build/finished', :version => 'v1') }
    let(:task)    { subject.new(payload, :event => 'build:finished') }

    it 'publishes a payload' do
      event.except(:payload).should == {
        :message => "travis.addons.pusher.task.run:completed",
        :uuid => Travis.uuid
      }
      event[:payload].except(:payload).should == {
        :msg => 'Travis::Addons::Pusher::Task#run for #<Build id=1> (channels: common)',
        # :repository => 'svenfuchs/minimal', # TODO
        :object_id => 1,
        :object_type => 'Build',
        :channels => ['common'],
        :event => 'build:finished',
        :client_event => 'build:finished'
      }
      event[:payload][:payload].should_not be_nil
    end
  end
end

