require 'spec_helper'

describe Travis::Addons::GithubStatus::Task do
  include Travis::Testing::Stubs

  let(:subject)    { Travis::Addons::GithubStatus::Task }
  let(:url)        { '/repos/svenfuchs/minimal/statuses/62aae5f70ceee39123ef' }
  let(:target_url) { 'https://travis-ci.org/svenfuchs/minimal/builds/1' }
  let(:payload)    { Travis::Api.data(build, for: 'event', version: 'v0') }
  let(:io)         { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
  end

  def run
    subject.new(payload, token: '12345').run
  end

  it 'posts status info for a created build' do
    build.stubs(state: :created)
    GH.expects(:post).with(url, state: 'pending', description: 'The Travis CI build is in progress', target_url: target_url)
    run
  end

  it 'posts status info for a passed build' do
    build.stubs(state: :passed)
    GH.expects(:post).with(url, state: 'success', description: 'The Travis CI build passed', target_url: target_url)
    run
  end

  it 'posts status info for a failed build' do
    build.stubs(state: :failed)
    GH.expects(:post).with(url, state: 'failure', description: 'The Travis CI build failed', target_url: target_url)
    run
  end

  it 'posts status info for a errored build' do
    build.stubs(state: :errored)
    GH.expects(:post).with(url, state: 'error', description: 'The Travis CI build could not complete due to an error', target_url: target_url)
    run
  end

  it 'posts status info for a canceled build' do
    build.stubs(state: :canceled)
    GH.expects(:post).with(url, state: 'error', description: 'The Travis CI build could not complete due to an error', target_url: target_url)
    run
  end

  it 'authenticates using the token passed into the task' do
    GH.expects(:with).with { |options| options[:token] == '12345' }
    run
  end

  describe 'logging' do
    it 'warns about a failed request' do
      GH.stubs(:post).raises(GH::Error.new(nil))
      expect {
        run
      }.to raise_error
      io.string.should include('[task]')
      io.string.should include('Could not update')
    end

    it "doesn't raise an error with bad credentials" do
      error = {response_status: 401}
      GH.stubs(:post).raises(GH::Error.new('failed', nil, error))
      expect {
        run
      }.to_not raise_error
    end
  end
end

