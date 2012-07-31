require 'spec_helper'

describe Travis::Task::GithubCommitStatus do
  include Travis::Testing::Stubs, Support::Formats

  let(:url)   { "https://api.github.com/repos/travis-repos/test-project-1/statuses/#{sha}" }
  let(:build_url)  { 'http://travis-ci.org/#!/travis-repos/test-project-1/1234' }
  let(:sha)   { 'ab2784e55bcf71ac9ef5f6ade8e02334c6524eea' }
  let(:token) { '12345' }
  let(:data)  { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:io)    { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
    WebMock.stub_request(:post, url).to_return(:status => 200, :body => '{}')
  end

  def run
    Travis::Task.run(:github_commit_status, data, :url => url, :sha => sha, :build_url => build_url, :token => token)
  end

  describe 'run' do
    it 'posts to the pull requests statuses sha url' do
      run
      a_request(:post, url).should have_been_made
    end

    describe 'using a pending build' do
      before :each do
        build.stubs(:result).returns(nil)
      end

      it 'sets the status of the commit to pending' do
        body = lambda do |request|
          decoded = ActiveSupport::JSON.decode(request.body)
          decoded.should == {
            "description" => "The Travis build is in progress",
            "target_url" => "http://travis-ci.org/#!/travis-repos/test-project-1/1234",
            "state" => "pending"
          }
        end

        # GH.expects(:post).with { |url, message| url == self.url }
        run
        a_request(:post, url).with(&body).should have_been_made
      end
    end

    describe 'using a passing build' do
      before :each do
        build.stubs(:result).returns(0)
      end

      it 'sets the status of the commit to success' do
        body = lambda do |request|
          decoded = ActiveSupport::JSON.decode(request.body)
          decoded.should == {
            "description" => "The Travis build passed",
            "target_url" => "http://travis-ci.org/#!/travis-repos/test-project-1/1234",
            "state" => "success"
          }
        end

        # GH.expects(:post).with { |url, message| url == self.url }
        run
        a_request(:post, url).with(&body).should have_been_made
      end
    end

    describe 'using a failing build' do
      before :each do
        build.stubs(:result).returns(1)
      end

      it 'sets the status of the commit to failure' do
        body = lambda do |request|
          decoded = ActiveSupport::JSON.decode(request.body)
          decoded.should == {
            "description" => "The Travis build failed",
            "target_url" => "http://travis-ci.org/#!/travis-repos/test-project-1/1234",
            "state" => "failure"
          }
        end

        run
        a_request(:post, url).with(&body).should have_been_made
      end
    end

    it 'authenticates using the token passed into the task' do
      run
      a_request(:post, url).with { |r| r.headers['Authorization'] == 'token 12345' }.should have_been_made
    end
  end

  describe 'logging' do
    it 'logs a successful request' do
      GH.stubs(:post)
      run
      io.string.should include('[githubcommitstatus] Successfully updated the PR status on https://api.github.com/repos/travis-repos/test-project-1/statuses/ab2784e55bcf71ac9ef5f6ade8e02334c6524eea')
    end

    it 'warns about a failed request' do
      GH.stubs(:with).raises(Faraday::Error::ClientError.new(:status => 403, :body => 'nono.'))
      run
      io.string.should include('[githubcommitstatus] Could not update the PR status on https://api.github.com/repos/travis-repos/test-project-1/statuses/ab2784e55bcf71ac9ef5f6ade8e02334c6524eea (the server responded with status 403: 403 nono.)')
    end
  end
end

