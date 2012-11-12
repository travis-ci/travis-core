require 'spec_helper'

describe Travis::Addons::Webhook::Instruments::Task do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::Webhook::Task }
  let(:payload)   { Travis::Api.data(build, for: 'webhook', type: 'build/finished', version: 'v1') }
  let(:task)      { subject.new(payload, targets: 'http://example.com') }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a event' do
    event.should publish_instrumentation_event(
      event: 'travis.addons.webhook.task.run:completed',
      message: 'Travis::Addons::Webhook::Task#run for #<Build id=1>',
    )
    event[:data].except(:payload).should == {
      repository: 'svenfuchs/minimal',
      object_id: 1,
      object_type: 'Build',
      targets: 'http://example.com'
    }
    event[:data][:payload].should_not be_nil
  end
end

