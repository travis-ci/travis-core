require 'spec_helper'

describe Travis::Notification::Instrument::Task::Pusher do
  include Travis::Testing::Stubs

  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.first }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  describe 'given a job:started event' do
    let(:data) { Travis::Api.data(test, :for => 'pusher', :type => 'job/started', :version => 'v1') }
    let(:task) { Travis::Task::Pusher.new(data, :event => 'job:test:started') }

    it 'publishes a payload' do
      event.except(:data).should == {
        :msg => 'Travis::Task::Pusher#run for #<Job id=1>',
        # :repository => 'svenfuchs/minimal', # TODO
        :object_id => 1,
        :object_type => 'Job',
        :result => nil,
        :channels => ['common'],
        :event => 'job:test:started',
        :client_event => 'job:started',
        :uuid => Travis.uuid
      }
      event[:data].should_not be_nil
    end
  end

  describe 'given a build:finished event' do
    let(:data) { Travis::Api.data(test, :for => 'pusher', :type => 'build/finished', :version => 'v1') }
    let(:task) { Travis::Task::Pusher.new(data, :event => 'build:finished') }

    it 'publishes a payload' do
      event.except(:data).should == {
        :msg => 'Travis::Task::Pusher#run for #<Build id=1>',
        # :repository => 'svenfuchs/minimal', # TODO
        :object_id => 1,
        :object_type => 'Build',
        :result => nil,
        :channels => ['common'],
        :event => 'build:finished',
        :client_event => 'build:finished',
        :uuid => Travis.uuid
      }
      event[:data].should_not be_nil
    end
  end
end

