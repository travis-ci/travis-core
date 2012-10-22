require 'spec_helper'

describe Travis::Event::Handler::GithubCommitStatus do
  include Travis::Testing::Stubs

  before :each do
    Travis::Features.start
    Travis::Event.stubs(:subscribers).returns [:github_commit_status]
    Broadcast.stubs(:by_repo).returns([broadcast])
  end

  describe 'subscription' do
    let(:handler) { Travis::Event::Handler::GithubCommitStatus.any_instance }

    it 'build:started notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:finished', build)
    end
  end

  describe 'a build which has started' do
    let(:handler) { Travis::Event::Handler::GithubCommitStatus.new('build:started', build) }

    describe 'given the request is a push event' do
      before :each do
        build.request.stubs(:pull_request? => false)
      end

      it 'does not handle the notification' do
        handler.expects(:handle)
        handler.notify
      end
    end

    describe 'given the request is a pull_request event' do
      before :each do
        build.request.stubs(:pull_request? => true)
      end

      it 'handles the notification' do
        handler.expects(:handle)
        handler.notify
      end
    end
  end

  describe 'a build which has finished' do
    let(:handler) { Travis::Event::Handler::GithubCommitStatus.new('build:finished', build) }

    describe 'given the request is a push event' do
      before :each do
        build.request.stubs(:pull_request? => false)
      end

      it 'does not handle the notification' do
        handler.expects(:handle)
        handler.notify
      end
    end

    describe 'given the request is a pull_request event' do
      before :each do
        build.request.stubs(:pull_request? => true)
      end

      it 'handles the notification' do
        handler.expects(:handle)
        handler.notify
      end
    end
  end

  describe 'instrumentation' do
    let(:handler) { Travis::Event::Handler::GithubCommitStatus.any_instance }

    it 'instruments with "travis.event.handler.github_commit_status.notify"' do
      ActiveSupport::Notifications.stubs(:publish)
      ActiveSupport::Notifications.expects(:publish).with do |event, data|
        event =~ /travis.event.handler.github_commit_status.notify/ && data[:target].is_a?(Travis::Event::Handler::GithubCommitStatus)
      end
      Travis::Event.dispatch('build:finished', build)
    end

    it 'meters on "travis.event.handler.github_commit_status.notify:complete"' do
      Metriks.expects(:timer).with('v1.travis.event.handler.github_commit_status.notify:completed').returns(stub('timer', :update => true))
      Travis::Event.dispatch('build:finished', build)
    end
  end
end
