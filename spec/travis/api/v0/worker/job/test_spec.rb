require 'spec_helper'

describe Travis::Api::V0::Worker::Job::Test do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V0::Worker::Job::Test.new(test).data }
  let(:foo)  { Travis::Model::EncryptedColumn.new(use_prefix: false).dump('bar') }
  let(:bar)  { Travis::Model::EncryptedColumn.new(use_prefix: false).dump('baz') }

  let(:settings) do
    Repository::Settings.load({
      'env_vars' => [
        { 'name' => 'FOO', 'value' => foo },
        { 'name' => 'BAR', 'value' => bar, 'public' => true }
      ],
      'timeout_hard_limit' => 180,
      'timeout_log_silence' => 20
    })
  end

  before :each do
    test.repository.stubs(:settings).returns(settings)
  end

  describe 'for a push request' do
    before :each do
      commit.stubs(:pull_request?).returns(false)
      commit.stubs(:ref).returns(nil)
    end

    it 'contains the expected data' do
      data.except('job', 'build', 'repository').should == {
        'type' => 'test',
        'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
        'queue' => 'builds.linux',
        'uuid' => Travis.uuid,
        'ssh_key' => nil,
        'source' => {
          'id' => 1,
          'number' => 2
        },
        'env_vars' => [
          { 'name' => 'FOO', 'value' => 'bar', 'public' => false },
          { 'name' => 'BAR', 'value' => 'baz', 'public' => true }
        ],
        'timeouts' => {
          'hard_limit' => 180 * 60, # worker handles timeouts in seconds
          'log_silence' => 20 * 60
        }
      }
    end

    it 'contains the expected job data' do
      data['job'].should == {
        'id' => 1,
        'number' => '2.1',
        'commit' => '62aae5f70ceee39123ef',
        'commit_range' => '0cd9ffaab2c4ffee...62aae5f70ceee39123ef',
        'commit_message' => 'the commit message',
        'branch' => 'master',
        'ref' => nil,
        'pull_request' => false,
        'state' => 'passed',
        'secure_env_enabled' => true
      }
    end

    it 'contains the expected build data (legacy)' do
      # TODO legacy. remove this once workers respond to a 'job' key
      data['build'].should == {
        'id' => 1,
        'number' => '2.1',
        'commit' => '62aae5f70ceee39123ef',
        'commit_range' => '0cd9ffaab2c4ffee...62aae5f70ceee39123ef',
        'commit_message' => 'the commit message',
        'branch' => 'master',
        'ref'    => nil,
        'pull_request' => false,
        'state' => 'passed',
        'secure_env_enabled' => true
      }
    end

    it 'contains the expected repo data' do
      data['repository'].should == {
        'id' => 1,
        'slug' => 'svenfuchs/minimal',
        'source_url' => 'git://github.com/svenfuchs/minimal.git',
        'api_url' => 'https://api.github.com/repos/svenfuchs/minimal',
        'last_build_id' => 1,
        'last_build_started_at' => json_format_time(Time.now.utc - 1.minute),
        'last_build_finished_at' => json_format_time(Time.now.utc),
        'last_build_number' => 2,
        'last_build_duration' => 60,
        'last_build_state' => 'passed',
        'description' => 'the repo description',
        'github_id' => 549743,
        'default_branch' => 'master'
      }
    end

    it "includes the tag name" do
      Travis.config.include_tag_name_in_worker_payload = true
      request.stubs(:tag_name).returns 'v1.2.3'
      data['job']['tag'].should == 'v1.2.3'
    end
  end

  describe 'for a pull request' do
    before :each do
      commit.stubs(:pull_request?).returns(true)
      commit.stubs(:ref).returns('refs/pull/180/merge')
      commit.stubs(:pull_request_number).returns(180)
      test.stubs(:secure_env_enabled?).returns(false)
    end

    describe 'from the same repository' do
      before do
        test.stubs(:secure_env_enabled?).returns(true)
      end

      it 'enables secure env variables' do
        data['job']['secure_env_enabled'].should be_true
        data['env_vars'].should have(2).items
      end
    end

    it 'contains the expected data' do
      data.except('job', 'build', 'repository').should == {
        'type' => 'test',
        'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
        'queue' => 'builds.linux',
        'uuid' => Travis.uuid,
        'ssh_key' => nil,
        'source' => {
          'id' => 1,
          'number' => 2
        },
        'env_vars' => [
          { 'name' => 'BAR', 'value' => 'baz', 'public' => true }
        ],
        'timeouts' => {
          'hard_limit' => 180 * 60, # worker handles timeouts in seconds
          'log_silence' => 20 * 60
        }
      }
    end

    it 'contains the expected job data' do
      data['job'].should == {
        'id' => 1,
        'number' => '2.1',
        'commit' => '62aae5f70ceee39123ef',
        'commit_range' => '0cd9ffaab2c4ffee...62aae5f70ceee39123ef',
        'commit_message' => 'the commit message',
        'branch' => 'master',
        'ref'    => 'refs/pull/180/merge',
        'pull_request' => 180,
        'state' => 'passed',
        'secure_env_enabled' => false
      }
    end

    it 'contains the expected build data (legacy)' do
      # TODO legacy. remove this once workers respond to a 'job' key
      data['build'].should == {
        'id' => 1,
        'number' => '2.1',
        'commit' => '62aae5f70ceee39123ef',
        'commit_range' => '0cd9ffaab2c4ffee...62aae5f70ceee39123ef',
        'commit_message' => 'the commit message',
        'branch' => 'master',
        'ref'    => 'refs/pull/180/merge',
        'pull_request' => 180,
        'state' => 'passed',
        'secure_env_enabled' => false
      }
    end

    it 'contains the expected repo data' do
      data['repository'].should == {
        'id' => 1,
        'slug' => 'svenfuchs/minimal',
        'source_url' => 'git://github.com/svenfuchs/minimal.git',
        'api_url' => 'https://api.github.com/repos/svenfuchs/minimal',
        'last_build_id' => 1,
        'last_build_started_at' => json_format_time(Time.now.utc - 1.minute),
        'last_build_finished_at' => json_format_time(Time.now.utc),
        'last_build_number' => 2,
        'last_build_duration' => 60,
        'last_build_state' => 'passed',
        'description' => 'the repo description',
        'github_id' => 549743,
        'default_branch' => 'master'
      }
    end
  end
end

