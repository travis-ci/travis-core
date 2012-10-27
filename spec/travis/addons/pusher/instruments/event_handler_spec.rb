require 'spec_helper'

describe Travis::Addons::Pusher::Instruments::EventHandler do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::Pusher::EventHandler }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    subject.any_instance.stubs(:handle)
  end

  describe 'given a job:started event' do
    it 'publishes a payload' do
      subject.notify('job:test:started', test)

      event.except(:payload).should == {
        :message => "travis.addons.pusher.event_handler.notify:completed",
        :uuid => Travis.uuid
      }
      event[:payload].except(:payload).should == {
        :msg => 'Travis::Addons::Pusher::EventHandler#notify(job:test:started) for #<Test id=1>',
        :repository => 'svenfuchs/minimal',
        :request_id => 1,
        :object_id => 1,
        :object_type => 'Test',
        :event => 'job:test:started',
      }
      event[:payload][:payload].should_not be_nil
    end
  end

  describe 'given a build:finished event' do
    it 'publishes a payload' do
      subject.notify('build:finished', build)

      event.except(:payload).should == {
        :message => "travis.addons.pusher.event_handler.notify:completed",
        :uuid => Travis.uuid
      }
      event[:payload].except(:payload).should == {
        :msg => 'Travis::Addons::Pusher::EventHandler#notify(build:finished) for #<Build id=1>',
        :repository => 'svenfuchs/minimal',
        :request_id => 1,
        :object_id => 1,
        :object_type => 'Build',
        :event => 'build:finished',
      }
      event[:payload][:payload].should_not be_nil
    end
  end
end

