require 'spec_helper'

describe Travis::Addons::Slack::Instruments::EventHandler do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::Slack::EventHandler }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:build)     { stub_build(config: { notifications: { slack: 'slack_room' } }) }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    subject.any_instance.stubs(:handle)
    subject.notify('build:finished', build)
  end

  it 'publishes a event' do
    event.should publish_instrumentation_event(
      event: 'travis.addons.slack.event_handler.notify:completed',
      message: 'Travis::Addons::Slack::EventHandler#notify:completed (build:finished) for #<Build id=1>',
    )
    event[:data].except(:payload).should == {
      event: 'build:finished',
      targets: ['slack_room'],
      repository: 'svenfuchs/minimal',
      request_id: 1,
      object_id: 1,
      object_type: 'Build'
    }
    event[:data][:payload].should_not be_nil
  end
end
