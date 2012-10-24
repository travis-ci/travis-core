require 'spec_helper'

describe Travis::Task::GithubStatus do
  include Travis::Testing::Stubs, Support::Formats

  let(:url)        { '/repos/svenfuchs/minimal/statuses/62aae5f70ceee39123ef' }
  let(:target_url) { 'http://travis-ci.org/#!/svenfuchs/minimal/builds/1' }
  let(:payload)    { Travis::Api.data(build, for: 'event', version: 'v0') }
  let(:io)         { StringIO.new }

  before do
    Travis::Features.start
    Travis.logger = Logger.new(io)
    Broadcast.stubs(:by_repo).returns([broadcast])
  end

  def run
    Travis::Task::GithubStatus.new(payload, token: '12345').run
  end

  it 'posts status info for a pending build' do
    build.stubs(result: nil)
    GH.expects(:post).with(url, state: 'pending', description: 'The Travis build is in progress', target_url: target_url)
    run
  end

  it 'posts status info for a passed build' do
    build.stubs(result: 0)
    GH.expects(:post).with(url, state: 'success', description: 'The Travis build passed', target_url: target_url)
    run
  end

  it 'posts status info for a failed build' do
    build.stubs(result: 1)
    GH.expects(:post).with(url, state: 'failure', description: 'The Travis build failed', target_url: target_url)
    run
  end

  it 'authenticates using the token passed into the task' do
    GH.expects(:with).with { |options| options[:token] == '12345' }
    run
  end

  describe 'logging' do
    it 'warns about a failed request' do
      GH.stubs(:post).raises(GH::Error.new(nil))
      run
      io.string.should include('[githubstatus]')
      io.string.should include('Could not update')
    end
  end
end

