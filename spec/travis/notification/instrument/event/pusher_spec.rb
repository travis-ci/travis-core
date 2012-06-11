require 'spec_helper'

describe Travis::Notification::Instrument::Event::Handler::Pusher do
  include Travis::Testing::Stubs

  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.first }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    handler.stubs(:handle)
    handler.notify
  end

  describe 'given a job:started event' do
    let(:handler) { Travis::Event::Handler::Pusher.new('job:test:started', test) }

    it 'publishes a payload' do
      event.except(:payload).should == {
        :msg => 'Travis::Event::Handler::Pusher#notify(job:test:started) for #<Job::Test id=1>',
        :repository => 'svenfuchs/minimal',
        :request_id => 1,
        :object_id => 1,
        :result => nil,
        :object_type => 'Job::Test',
        :event => 'job:test:started'
      }
      event[:payload].should_not be_nil
    end
  end

  describe 'given a build:finished event' do
    let(:handler) { Travis::Event::Handler::Pusher.new('build:finished', build) }

    it 'publishes a payload' do
      event.except(:payload).should == {
        :msg => 'Travis::Event::Handler::Pusher#notify(build:finished) for #<Build id=1>',
        :repository => 'svenfuchs/minimal',
        :request_id => 1,
        :object_id => 1,
        :result => nil,
        :object_type => 'Build',
        :event => 'build:finished'
      }
      event[:payload].should_not be_nil
    end
  end
end
