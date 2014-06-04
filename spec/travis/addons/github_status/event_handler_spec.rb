require 'spec_helper'

describe Travis::Addons::GithubStatus::EventHandler do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::GithubStatus::EventHandler }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  before do
    Travis::Features.stubs(feature_deactivated?: false)
    User.stubs(:with_email).returns(nil)
  end

  describe 'subscription' do
    let(:handler) { subject.any_instance }

    before :each do
      Travis::Event.stubs(:subscribers).returns [:github_status]
      handler.stubs(:handle => true, :handle? => true)
      Travis::Api.stubs(:data).returns(stub('data'))
    end

    it 'build:created notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:created', build)
    end

    it 'build:started notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:finished', build)
    end

    it 'build:canceled notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:canceled', build)
    end
  end

  describe 'handler' do
    let(:build_url) { 'http://travis-ci.org/svenfuchs/minimal/builds/1' }
    let(:task)      { Travis::Addons::GithubStatus::Task }

    attr_reader :event

    before :each do
      Travis.stubs(:run_service).returns(user)
    end

    def notify
      subject.notify(event, build)
    end

    it 'triggers a task if the build is a push request and has started' do
      build.stubs(:pull_request?).returns(false)
      @event = 'build:started'
      task.expects(:run).with(:github_status, payload, tokens: { 'svenfuchs' => 'token' })
      notify
    end

    it 'triggers a task if the build is a pull request and has started' do
      build.stubs(:pull_request?).returns(true)
      @event = 'build:started'
      task.expects(:run).with(:github_status, payload, tokens: { 'svenfuchs' => 'token' })
      notify
    end

    it 'triggers a task if the build is a push request and has finished' do
      build.stubs(:pull_request?).returns(false)
      @event = 'build:finished'
      task.expects(:run).with(:github_status, payload, tokens: { 'svenfuchs' => 'token' })
      notify
    end

    it 'triggers a task if the build is a pull request and has finished' do
      build.stubs(:pull_request?).returns(true)
      @event = 'build:finished'
      task.expects(:run).with(:github_status, payload, tokens: { 'svenfuchs' => 'token' })
      notify
    end

    it 'gets the token for the build committer' do
      committer = stub_user(login: 'jdoe', github_oauth_token: 'commit-token')
      committer.stubs(:permission?).with(repository_id: repository.id, push: true).returns(true)
      User.stubs(:with_email).with(commit.committer_email).returns(committer)
      task.expects(:run).with { |_, _, options| options[:tokens]['jdoe'] == 'commit-token' }
      notify
    end

    it 'gets the token for someone with push access' do
      push_user = stub_user(login: 'jdoe', github_oauth_token: 'push-token')
      build.repository.stubs(users_with_permission: [push_user])
      task.expects(:run).with { |_, _, options| options[:tokens]['jdoe'] == 'push-token' }
      notify
    end

    it 'does not trigger a task if no tokens are available' do
      build.repository.stubs(users_with_permission: [])
      Travis.stubs(:run_service).returns(nil)

      task.expects(:run).never
      notify
    end
  end
end
