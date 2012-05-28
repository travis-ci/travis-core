require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe Travis::Task::Github do
  include Support::ActiveRecord
  include Support::Formats

  let(:url)     { 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments' }
  let(:request) { Factory(:request, :head_commit => 'head', :base_commit => 'base') }
  let(:build)   { Factory(:build, :request => request) }
  let(:data)    { Travis::Api.data(build, :for => 'notifications', :version => 'v2') }
  let(:io)      { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
    stub_request(:post, 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments').to_return(:status => 200, :body => '{}')
  end

  def run
    Travis::Task::Github.new(url, data).run
  end

  describe 'run' do
    it 'posts to the request comments_url' do
      run
      a_request(:post, url).should have_been_made
    end

    it 'posts a comment to github' do
      comment = "This pull request [passes](http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}) (merged #{request.head_commit[0..7]} into #{request.base_commit[0..7]})."
      body = lambda { |request| ActiveSupport::JSON.decode(request.body)['body'].should == comment }

      run
      a_request(:post, url).with(&body).should have_been_made
    end

    it 'authenticates as travisbot using the token' do
      run
      a_request(:post, url).with { |r| r.headers['Authorization'] == 'token travisbot-token' }.should have_been_made
    end
  end

  describe 'logging' do
    it 'logs a successful request' do
      GH.stubs(:post)
      run
      io.string.should include('[github] Successfully commented on https://api.github.com')
    end

    it 'warns about a failed request' do
      GH.stubs(:with).raises(Faraday::Error::ClientError.new(:status => 403, :body => 'nono.'))
      run
      io.string.should include('[github] Could not comment on https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments (403 nono.)')
    end
  end
end

