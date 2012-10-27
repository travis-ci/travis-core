require 'spec_helper'

describe Travis::Addons::GithubStatus::EventHandler do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::GithubStatus::EventHandler }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  describe 'subscription' do
    let(:handler) { subject.any_instance }

    before :each do
      Travis::Event.stubs(:subscribers).returns [:github_status]
      handler.stubs(:handle => true, :handle? => true)
      Travis::Api.stubs(:data).returns(stub('data'))
    end

    it 'build:started notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:finished', build)
    end
  end

  describe 'handler' do
    let(:build_url) { 'http://travis-ci.org/svenfuchs/minimal/builds/1' }

    attr_reader :url, :event

    def notify
      subject.notify(event, build)
    end

    it 'triggers a task if the build is a push request and has started' do
      build.stubs(:pull_request?).returns(false)
      @event = 'build:started'
      @url = 'repos/svenfuchs/minimal/statuses/62aae5f70ceee39123ef'
      Travis::Task.expects(:run).with(:github_status, payload, token: 'token')
      notify
    end

    it 'triggers a task if the build is a pull request and has started' do
      build.stubs(:pull_request?).returns(true)
      @event = 'build:started'
      @url = 'repos/svenfuchs/minimal/statuses/head-commit'
      Travis::Task.expects(:run).with(:github_status, payload, token: 'token')
      notify
    end

    it 'triggers a task if the build is a push request and has finished' do
      build.stubs(:pull_request?).returns(false)
      @event = 'build:finished'
      @url = 'repos/svenfuchs/minimal/statuses/62aae5f70ceee39123ef'
      Travis::Task.expects(:run).with(:github_status, payload, token: 'token')
      notify
    end

    it 'triggers a task if the build is a pull request and has finished' do
      build.stubs(:pull_request?).returns(true)
      @event = 'build:finished'
      @url = 'repos/svenfuchs/minimal/statuses/head-commit'
      Travis::Task.expects(:run).with(:github_status, payload, token: 'token')
      notify
    end
  end

  # describe 'instrumentation' do
  #   let(:handler) { Travis::Event::Handler::GithubStatus.any_instance }

  #   it 'instruments with "travis.event.handler.github_commit_status.notify"' do
  #     ActiveSupport::Notifications.stubs(:publish)
  #     ActiveSupport::Notifications.expects(:publish).with do |event, data|
  #       event =~ /travis.event.handler.github_commit_status.notify/ && data[:target].is_a?(Travis::Event::Handler::GithubStatus)
  #     end
  #     Travis::Event.dispatch('build:finished', build)
  #   end

  #   it 'meters on "travis.event.handler.github_commit_status.notify:complete"' do
  #     Metriks.expects(:timer).with('v1.travis.event.handler.github_commit_status.notify:completed').returns(stub('timer', :update => true))
  #     Travis::Event.dispatch('build:finished', build)
  #   end
  # end
end
