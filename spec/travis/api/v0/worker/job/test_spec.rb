require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::V0::Worker::Job::Test do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::V0::Worker::Job::Test.new(test).data }

  describe 'for a push request' do
    before :each do
      commit.stubs(:pull_request?).returns(false)
      commit.stubs(:ref).returns(nil)
    end

    it 'contains the expected data' do
      data.should == {
        'type' => 'test',
        'job' => {
          'id' => 1,
          'number' => '2.1',
          'commit' => '62aae5f70ceee39123ef',
          'branch' => 'master'
        },
        # TODO legacy. remove this once workers respond to a 'job' key
        'build' => {
          'id' => 1,
          'number' => '2.1',
          'commit' => '62aae5f70ceee39123ef',
          'branch' => 'master'
        },
        'repository' => {
          'id' => 1,
          'slug' => 'svenfuchs/minimal',
          'source_url' => 'git://github.com/svenfuchs/minimal.git'
        },
        'config' => {
          'rvm' => '1.8.7',
          'gemfile' => 'test/Gemfile.rails-2.3.x'
        },
        'queue' => 'builds.common'
      }
    end
  end

  describe 'for a pull request' do
    before :each do
      commit.stubs(:pull_request?).returns(true)
      commit.stubs(:ref).returns('refs/pull/180/merge')
    end

    it 'contains the expected data' do
      data.should == {
        'type' => 'test',
        'job' => {
          'id' => 1,
          'number' => '2.1',
          'commit' => '62aae5f70ceee39123ef',
          'branch' => 'master',
          'ref'    => 'refs/pull/180/merge'
        },
        # TODO legacy. remove this once workers respond to a 'job' key
        'build' => {
          'id' => 1,
          'number' => '2.1',
          'commit' => '62aae5f70ceee39123ef',
          'branch' => 'master',
          'ref'    => 'refs/pull/180/merge'
        },
        'repository' => {
          'id' => 1,
          'slug' => 'svenfuchs/minimal',
          'source_url' => 'git://github.com/svenfuchs/minimal.git'
        },
        'config' => {
          'rvm' => '1.8.7',
          'gemfile' => 'test/Gemfile.rails-2.3.x'
        },
        'queue' => 'builds.common'
      }
    end
  end
end

