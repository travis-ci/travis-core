require 'spec_helper'

describe Travis::Event::Handler::Github do
  include Support::Stubs
  # include Support::ActiveRecord

  # let(:request) { Factory(:request, :event_type => 'pull_request', :comments_url => 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments', :base_commit => 'a3585bf3f9691ba396c38194c4b4920e51f1490b', :head_commit => '1317692c01d0c3a20b89ea634d06cd66b8c517d3') }
  # let(:build)   { Factory(:build, :request => request) }

  before do
    Travis.config.notifications = [:github]
  end

  describe 'subscription' do
    let(:handler) { Travis::Event::Handler::Github.any_instance }

    it 'build:started does not notify' do
      handler.expects(:notify).never
      Travis::Event.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:finished', build)
    end
  end

  describe 'given the request is not a pull_request event' do
    let(:handler) { Travis::Event::Handler::Github.new('build:finished', build) }

    before :each do
      build.request.stubs(:pull_request? => false)
    end

    it 'does not handle the notification' do
      handler.expects(:handle).never
      handler.notify
    end
  end

  describe 'given the request is a pull_request event' do
    let(:handler) { Travis::Event::Handler::Github.new('build:finished', build) }

    before :each do
      build.request.stubs(:pull_request? => true)
    end

    it 'handles the notification' do
      handler.expects(:handle)
      handler.notify
    end
  end
end
