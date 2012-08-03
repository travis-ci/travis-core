require 'spec_helper'

describe Travis::Notification::Instrument::Event::Handler::GithubCommitStatus do
  include Travis::Testing::Stubs

  let(:handler)   { Travis::Event::Handler::GithubCommitStatus.new('build:finished', build) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
  end

  it 'publishes a payload for push events' do
    handler.stubs(:handle)
    handler.notify

    event.except(:payload).should == {
      :message => "travis.event.handler.github_commit_status.notify:completed",
      :uuid => Travis.uuid
    }

    event[:payload].except(:payload).should == {
      :msg => 'Travis::Event::Handler::GithubCommitStatus#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build',
      :event => 'build:finished',
      :url => 'https://api.github.com/repos/svenfuchs/minimal/statuses/62aae5f70ceee39123ef',
    }

    event[:payload][:payload].should_not be_nil
  end

  it 'publishes a payload for pull request events' do
    build.request.stubs(:pull_request?).returns(true)
    handler.stubs(:handle)
    handler.notify

    event.except(:payload).should == {
      :message => "travis.event.handler.github_commit_status.notify:completed",
      :uuid => Travis.uuid
    }

    event[:payload].except(:payload).should == {
      :msg => 'Travis::Event::Handler::GithubCommitStatus#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build',
      :event => 'build:finished',
      :url => 'https://api.github.com/repos/svenfuchs/minimal/statuses/head-commit',
    }

    event[:payload][:payload].should_not be_nil
  end
end
