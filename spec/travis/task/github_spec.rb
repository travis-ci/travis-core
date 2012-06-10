require 'spec_helper'

describe Travis::Task::Github do
  include Travis::Testing::Stubs, Support::Formats

  let(:passing_build) { build }
  let(:failing_build) { stub_build(:result => 1) }

  let(:url)     { 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments' }
  let(:io)      { StringIO.new }

  def data(build)
    Travis::Api.data(build, :for => 'event', :version => 'v2')
  end

  before do
    Travis.logger = Logger.new(io)
    WebMock.stub_request(:post, 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments').to_return(:status => 200, :body => '{}')
  end

  def run(build = passing_build)
    Travis::Task.run(:github, url, data(build))
  end

  describe 'run' do
    it 'posts to the request comments_url' do
      run
      a_request(:post, url).should have_been_made
    end

    describe 'using a passing build' do
      it 'posts a comment to github' do
        comment = "This pull request [passes](http://travis-ci.org/svenfuchs/minimal/builds/#{passing_build.id}) (merged #{request.head_commit[0..7]} into #{request.base_commit[0..7]})."
        body = lambda { |request| ActiveSupport::JSON.decode(request.body)['body'].should == comment }

        run
        a_request(:post, url).with(&body).should have_been_made
      end
    end

    describe 'using a failing build' do
      it 'posts a comment to github' do
        comment = "This pull request [fails](http://travis-ci.org/svenfuchs/minimal/builds/#{failing_build.id}) (merged #{request.head_commit[0..7]} into #{request.base_commit[0..7]})."
        body = lambda { |request| ActiveSupport::JSON.decode(request.body)['body'].should == comment }

        run(failing_build)
        a_request(:post, url).with(&body).should have_been_made
      end
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
      io.string.should include('[github] Could not comment on https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments (the server responded with status 403: 403 nono.)')
    end
  end
end

