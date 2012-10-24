require 'spec_helper'

describe Travis::Notification::Instrument::Event::Handler::GithubStatus do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Event::Handler::GithubStatus }
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
      :message => "travis.event.handler.github_status.notify:completed",
      :uuid => Travis.uuid
    }

    event[:payload].except(:payload).should == {
      :msg => 'Travis::Event::Handler::GithubStatus#notify(build:finished) for #<Build id=1>',
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
      :message => "travis.event.handler.github_status.notify:completed",
      :uuid => Travis.uuid
    }

    event[:payload].except(:payload).should == {
      :msg => 'Travis::Event::Handler::GithubStatus#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build',
      :event => 'build:finished'
    }

    event[:payload][:payload].should_not be_nil
  end
end
