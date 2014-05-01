require 'spec_helper'

describe Travis::Addons::GithubStatus::Instruments::EventHandler do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::GithubStatus::EventHandler }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis.stubs(:run_service).returns(user)
    Travis::Notification.publishers.replace([publisher])
    Travis::Features.stubs(feature_deactivated?: false)
    User.stubs(with_email: nil)
    subject.any_instance.stubs(:handle)
  end

  it 'publishes a event for push events' do
    build.request.stubs(:pull_request?).returns(false)
    subject.notify('build:finished', build)

    event.should publish_instrumentation_event(
      event: 'travis.addons.github_status.event_handler.notify:completed',
      message: 'Travis::Addons::GithubStatus::EventHandler#notify:completed (build:finished) for #<Build id=1>',
    )

    event[:data].except(:payload).should == {
      repository: 'svenfuchs/minimal',
      request_id: 1,
      object_id: 1,
      object_type: 'Build',
      event: 'build:finished'
    }

    event[:data][:payload].should_not be_nil
  end

  it 'publishes a event for pull request events' do
    build.request.stubs(:pull_request?).returns(true)
    subject.notify('build:finished', build)

    event.should publish_instrumentation_event(
      event: 'travis.addons.github_status.event_handler.notify:completed',
      message: 'Travis::Addons::GithubStatus::EventHandler#notify:completed (build:finished) for #<Build id=1>',
    )

    event[:data].except(:payload).should == {
      repository: 'svenfuchs/minimal',
      request_id: 1,
      object_id: 1,
      object_type: 'Build',
      event: 'build:finished'
    }

    event[:data][:payload].should_not be_nil
  end
end
