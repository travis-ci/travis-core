require 'spec_helper'

describe Travis::Addons::Email::Instruments::Task do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::Email::Task }
  let(:payload)   { Travis::Api.data(build, for: 'event', version: 'v0') }
  let(:task)      { subject.new(payload, recipients: %w(svenfuchs@artweb-design.de)) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a event' do
    event.should publish_instrumentation_event(
      event: 'travis.addons.email.task.run:completed',
      message: 'Travis::Addons::Email::Task#run:completed for #<Build id=1>',
    )
    event[:data].except(:payload).should == {
      repository: 'svenfuchs/minimal',
      object_id: 1,
      object_type: 'Build',
      email: :finished_email,
      recipients: %w(svenfuchs@artweb-design.de)
    }
    event[:data][:payload].should_not be_nil
  end
end

