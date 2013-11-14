require 'spec_helper'

describe Travis::Addons::Email::Instruments::EventHandler do
  include Travis::Testing::Stubs

  let(:build)   { stub_build(state: :failed, repository: repository, on_default_branch?: true) }
  let(:subject)   { Travis::Addons::Email::EventHandler }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }
  let(:repository) {
    stub_repo(users: [stub_user(email: 'svenfuchs@artweb-design.de')])
  }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    subject.any_instance.stubs(:handle)
    subject.notify('build:finished', build)
  end

  it 'publishes a event' do
    event.should publish_instrumentation_event(
      event: 'travis.addons.email.event_handler.notify:completed',
      message: 'Travis::Addons::Email::EventHandler#notify:completed (build:finished) for #<Build id=1>',
    )
    event[:data].except(:payload).should == {
      repository: 'svenfuchs/minimal',
      request_id: 1,
      object_id: 1,
      object_type: 'Build',
      event: 'build:finished',
      recipients: ['svenfuchs@artweb-design.de'],
    }
    event[:data][:payload].should_not be_nil
  end
end

