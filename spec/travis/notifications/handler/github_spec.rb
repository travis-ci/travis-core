require 'spec_helper'
require 'support/active_record'
require 'support/formats'
require 'support/webmock'
require 'json'

describe Travis::Notifications::Handler::Github do
  include Support::ActiveRecord
  include Support::Formats
  include Support::Webmock

  let(:github)  { Travis::Notifications::Handler::Github.new }
  let(:request) { Factory(:request, :event_type => 'pull_request', :comments_url => 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments') }
  let(:build)   { Factory(:build, :request => request) }
  let(:io)      { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
    Travis.config.notifications = [:github]
    stub_request(:post, 'https://travisbot:password@api.github.com/repos/travis-repos/test-project-1/issues/1/comments').to_return(:status => 200, :body => '{}')
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
    let(:url) { build.request.comments_url.gsub('//', '//travisbot:password@') }

    it 'posts to the request comments_url' do
      github.notify('build:finished', build)
      a_request(:post, url).should have_been_made
    end

    it 'posts a comment to github' do
      body = ActiveSupport::JSON.encode(:body => "This pull request was tested on [Travis CI](http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}) and has passed.")
      github.notify('build:finished', build)
      a_request(:post, url).with { |r| r.body == body }.should have_been_made
    end

    # can't test auth separately because it's already part of the url with username/password
    #
    # it 'authenticates as travisbot using the token' do
    #   github.notify('build:finished', build)
    #   a_request(:post, url).with { |r| p r.headers; r.headers['Authorization'] == 'token: travisbot-token' }.should have_been_made
    # end
  end

  describe 'logging' do
    it 'logs a successful request' do
      GH.stubs(:post)
      github.notify('build:finished', build)
      io.string.should include('[github] Successfully commented on https://api.github.com')
    end

    it 'warns about a failed request' do
      GH.stubs(:with).raises(Faraday::Error::ClientError.new(:status => 403, :body => 'nono.'))
      github.notify('build:finished', build)
      io.string.should include('[github] Could not comment on https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments (403 nono.)')
    end
  end
end
