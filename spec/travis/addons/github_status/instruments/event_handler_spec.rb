require 'spec_helper'

describe Travis::Addons::GithubStatus::Instruments::EventHandler do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::GithubStatus::EventHandler }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    subject.any_instance.stubs(:handle)
  end

  it 'publishes a payload for push events' do
    build.request.stubs(:pull_request?).returns(false)
    subject.notify('build:finished', build)

    event.except(:payload).should == {
      :message => "travis.addons.github_status.event_handler.notify:completed",
      :uuid => Travis.uuid
    }

    event[:payload].except(:payload).should == {
      :msg => 'Travis::Addons::GithubStatus::EventHandler#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build',
      :event => 'build:finished'
    }

    event[:payload][:payload].should_not be_nil
  end

  it 'publishes a payload for pull request events' do
    build.request.stubs(:pull_request?).returns(true)
    subject.notify('build:finished', build)

    event.except(:payload).should == {
      :message => "travis.addons.github_status.event_handler.notify:completed",
      :uuid => Travis.uuid
    }

    event[:payload].except(:payload).should == {
      :msg => 'Travis::Addons::GithubStatus::EventHandler#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build',
      :event => 'build:finished'
    }

    event[:payload][:payload].should_not be_nil
  end
end
