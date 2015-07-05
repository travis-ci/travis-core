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
    it 'publishes a event' do
      subject.notify('job:test:started', test)

      event.should publish_instrumentation_event(
        event: 'travis.addons.pusher.event_handler.notify:completed',
        message: 'Travis::Addons::Pusher::EventHandler#notify:completed (job:test:started) for #<Test id=1>',
      )
      event[:data].except(:payload).should == {
        repository: 'svenfuchs/minimal',
        request_id: 1,
        object_id: 1,
        object_type: 'Test',
        event: 'job:test:started',
      }
      # TODO broken, see: https://github.com/travis-ci/travis-core/commit/f56848ffb2fea94ff79a3cd9892ea2e4fa7de384#commitcomment-12006268
      # @drogus, could you have a look at this?
      #
      # event[:data][:payload].should_not be_nil
    end
  end

  describe 'given a build:finished event' do
    it 'publishes a event' do
      subject.notify('build:finished', build)

      event.should publish_instrumentation_event(
        event: 'travis.addons.pusher.event_handler.notify:completed',
        message: 'Travis::Addons::Pusher::EventHandler#notify:completed (build:finished) for #<Build id=1>',
      )
      event[:data].except(:payload).should == {
        repository: 'svenfuchs/minimal',
        request_id: 1,
        object_id: 1,
        object_type: 'Build',
        event: 'build:finished',
      }
      event[:data][:payload].should_not be_nil
    end
  end
end

