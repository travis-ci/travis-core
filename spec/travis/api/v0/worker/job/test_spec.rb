require 'spec_helper'

describe Travis::Api::V0::Worker::Job::Test do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V0::Worker::Job::Test.new(test).data }

  describe 'for a push request' do
    before :each do
      commit.stubs(:pull_request?).returns(false)
      commit.stubs(:ref).returns(nil)
    end

    it 'contains the expected data' do
      data.except('job', 'build', 'repository').should == {
        'type' => 'test',
        'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
        'queue' => 'builds.common',
        'uuid' => Travis.uuid,
        'source' => {
          'id' => 1,
          'number' => 2
        },
      }
    end

    it 'contains the expected job data' do
      data['job'].should == {
        'id' => 1,
        'number' => '2.1',
        'commit' => '62aae5f70ceee39123ef',
        'commit_range' => '0cd9ffaab2c4ffee...62aae5f70ceee39123ef',
        'branch' => 'master',
        'ref' => nil,
        'pull_request' => false,
        'state' => 'passed'
      }
    end

    it 'contains the expected build data (legacy)' do
      # TODO legacy. remove this once workers respond to a 'job' key
      data['build'].should == {
        'id' => 1,
        'number' => '2.1',
        'commit' => '62aae5f70ceee39123ef',
        'commit_range' => '0cd9ffaab2c4ffee...62aae5f70ceee39123ef',
        'branch' => 'master',
        'ref'    => nil,
        'pull_request' => false,
        'state' => 'passed'
      }
    end

    it 'contains the expected repo data' do
      data['repository'].should == {
        'id' => 1,
        'slug' => 'svenfuchs/minimal',
        'source_url' => 'git://github.com/svenfuchs/minimal.git',
        'last_build_id' => 1,
        'last_build_started_at' => json_format_time(Time.now.utc - 1.minute),
        'last_build_finished_at' => json_format_time(Time.now.utc),
        'last_build_number' => 2,
        'last_build_duration' => 60,
        'last_build_state' => 'passed',
        'description' => 'the repo description'
      }
    end
  end

  describe 'for a pull request' do
    before :each do
      commit.stubs(:pull_request?).returns(true)
      commit.stubs(:ref).returns('refs/pull/180/merge')
      commit.stubs(:pull_request_number).returns(180)
    end

    it 'contains the expected data' do
      data.except('job', 'build', 'repository').should == {
        'type' => 'test',
        'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
        'queue' => 'builds.common',
        'uuid' => Travis.uuid,
        'source' => {
          'id' => 1,
          'number' => 2
        },
      }
    end

    it 'contains the expected job data' do
      data['job'].should == {
        'id' => 1,
        'number' => '2.1',
        'commit' => '62aae5f70ceee39123ef',
        'commit_range' => '0cd9ffaab2c4ffee...62aae5f70ceee39123ef',
        'branch' => 'master',
        'ref'    => 'refs/pull/180/merge',
        'pull_request' => 180,
        'state' => 'passed'
      }
    end

    it 'contains the expected build data (legacy)' do
      # TODO legacy. remove this once workers respond to a 'job' key
      data['build'].should == {
        'id' => 1,
        'number' => '2.1',
        'commit' => '62aae5f70ceee39123ef',
        'commit_range' => '0cd9ffaab2c4ffee...62aae5f70ceee39123ef',
        'branch' => 'master',
        'ref'    => 'refs/pull/180/merge',
        'pull_request' => 180,
        'state' => 'passed'
      }
    end

    it 'contains the expected repo data' do
      data['repository'].should == {
        'id' => 1,
        'slug' => 'svenfuchs/minimal',
        'source_url' => 'git://github.com/svenfuchs/minimal.git',
        'last_build_id' => 1,
        'last_build_started_at' => json_format_time(Time.now.utc - 1.minute),
        'last_build_finished_at' => json_format_time(Time.now.utc),
        'last_build_number' => 2,
        'last_build_duration' => 60,
        'last_build_state' => 'passed',
        'description' => 'the repo description'
      }
    end
  end
end

