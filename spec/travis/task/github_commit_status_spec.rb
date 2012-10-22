require 'spec_helper'

describe Travis::Task::GithubCommitStatus do
  include Travis::Testing::Stubs, Support::Formats

  let(:url)       { "repos/travis-repos/test-project-1/statuses/#{sha}" }
  let(:full_url)  { "https://api.github.com/#{url}" }
  let(:build_url) { 'http://travis-ci.org/#!/travis-repos/test-project-1/1234' }
  let(:sha)       { 'ab2784e55bcf71ac9ef5f6ade8e02334c6524eea' }
  let(:token)     { '12345' }
  let(:data)      { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:io)        { StringIO.new }

  before do
    Travis::Features.start
    Travis.logger = Logger.new(io)
    WebMock.stub_request(:post, full_url).to_return(:status => 200, :body => '{}')
    Broadcast.stubs(:by_repo).returns([broadcast])
  end

  def run
    Travis::Task::GithubCommitStatus.new(data, :url => url, :sha => sha, :build_url => build_url, :token => token).run
  end

  describe 'run' do
    it 'posts to the pull requests statuses sha url' do
      run
      a_request(:post, full_url).should have_been_made
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
        a_request(:post, full_url).with(&body).should have_been_made
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
        a_request(:post, full_url).with(&body).should have_been_made
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
        a_request(:post, full_url).with(&body).should have_been_made
      end
    end

    it 'authenticates using the token passed into the task' do
      run
      a_request(:post, full_url).with { |r| r.headers['Authorization'] == 'token 12345' }.should have_been_made
    end
  end

  describe 'logging' do
    it 'warns about a failed request' do
      GH.stubs(:post).raises(GH::Error.new(nil))
      run
      io.string.should include('[githubcommitstatus]')
      io.string.should include('Could not update')
    end
  end
end

