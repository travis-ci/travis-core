require 'spec_helper'
require 'support/active_record'
require 'support/formats'
require 'json'

describe Travis::Notifications::Handler::Github do
  include Support::ActiveRecord
  include Support::Formats

  let(:github)  { Travis::Notifications::Handler::Github.new }
  let(:request) { Factory(:request, :event_type => 'pull_request', :comments_url => 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments') }
  let(:build)   { Factory(:build, :request => request) }
  let(:io)      { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
    Travis.config.notifications = [:github]
  end

  describe 'given the request is a push event' do
    before :each do
      build.request.event_type = 'push'
    end

    it 'it does not add a github comment' do
      Travis::Notifications::Handler::Github.any_instance.expects(:add_comment).never
      Travis::Notifications.dispatch('build:finished', build)
    end
  end

  describe 'given the request is a pull_request event' do
    it 'it adds a github comment' do
      Travis::Notifications::Handler::Github.any_instance.expects(:add_comment).with(build)
      Travis::Notifications.dispatch('build:finished', build)
    end
  end

  describe 'add_comment' do
    it 'posts to the request comments_url' do
      comment = "This pull request was tested on [Travis CI](http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}) and has passed."
      GH.expects(:post).with(anything, :body => comment)
      github.notify('build:finished', build)
    end

    it 'posts a comment to github' do
      GH.expects(:post).with(request.comments_url, anything)
      github.notify('build:finished', build)
    end
  end

  describe 'logging' do
    it 'logs a successful request' do
      GH.stubs(:post)
      github.notify('build:finished', build)
      io.string.should include('[github] Successfully commented on https://api.github.com')
    end

    it 'warns about a failed request' do
      GH.stubs(:post).raises(StandardError) # TODO use future GH exception
      github.notify('build:finished', build)
      io.string.should include('[github] Could not comment on https://api.github.com')
    end
  end
end
