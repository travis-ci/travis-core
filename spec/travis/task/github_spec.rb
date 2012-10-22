require 'spec_helper'

describe Travis::Task::Github do
  include Travis::Testing::Stubs, Support::Formats

  let(:url)  { 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments' }
  let(:data) { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:io)   { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
    GH.stubs(:head)
    WebMock.stub_request(:post, 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments').to_return(:status => 200, :body => '{}')
    Broadcast.stubs(:by_repo).returns([broadcast])
  end

  def run
    Travis::Task::Github.new(data, :url => url).run
  end

  describe 'run' do
    it 'posts to the request comments_url' do
      run
      a_request(:post, url).should have_been_made
    end

    it 'does not post if the bot has no access to the comments' do
      GH.stubs(:head).raises(GH::Error.new(nil))
      run
      a_request(:post, url).should_not have_been_made
    end

    describe 'using a passing build' do
      before :each do
        build.stubs(:result).returns(0)
      end

      it 'posts a comment to github' do
        comment = "This pull request [passes](http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}) (merged #{request.head_commit[0..7]} into #{request.base_commit[0..7]})."
        body = lambda { |request| ActiveSupport::JSON.decode(request.body)['body'].should == comment }

        GH.expects(:post).with { |url, message| url == self.url }
        run
      end
    end

    describe 'using a failing build' do
      before :each do
        build.stubs(:result).returns(1)
      end

      it 'posts a comment to github' do
        comment = "This pull request [fails](http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}) (merged #{request.head_commit[0..7]} into #{request.base_commit[0..7]})."
        body = lambda { |request| ActiveSupport::JSON.decode(request.body)['body'].should == comment }

        run
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
      GH.stubs(:post).raises(GH::Error.new(nil))
      run
      io.string.should include('[github]')
      io.string.should include('Could not comment')
    end
  end
end

