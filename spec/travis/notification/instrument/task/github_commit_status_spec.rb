require 'spec_helper'

describe Travis::Notification::Instrument::Task::GithubCommitStatus do
  include Travis::Testing::Stubs

  let(:data)      { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:build_url) { 'http://travis-ci.org/#!/travis-repos/test-project-1/1234' }
  let(:url)       { "/repos/svenfuchs/minimal/statuses/#{sha}" }
  let(:sha)       { 'ab2784e55bcf71ac9ef5f6ade8e02334c6524eea' }
  let(:token)     { '12345' }
  let(:task)      { Travis::Task::GithubCommitStatus.new(data, :url => url, :sha => sha, :build_url => build_url, :token => token) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.task.github_commit_status.run:completed",
            :uuid => Travis.uuid
    }
    event[:payload].except(:data).should == {
      :msg => 'Travis::Task::GithubCommitStatus#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :url => 'https://api.github.com/repos/svenfuchs/minimal/statuses/ab2784e55bcf71ac9ef5f6ade8e02334c6524eea'
    }
    event[:payload][:data].should_not be_nil
  end
end

