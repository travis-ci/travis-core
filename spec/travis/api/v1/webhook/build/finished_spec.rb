require 'spec_helper'

describe Travis::Api::V1::Webhook::Build::Finished do
  include Travis::Testing::Stubs, Support::Formats

  let(:data)    { Travis::Api::V1::Webhook::Build::Finished.new(build, options).data }
  let(:options) { { :include_logs => true } }

  it 'includes the build data' do
    data.except('repository', 'matrix').should == {
      'id' => 1,
      'number' => 2,
      'status' => 0,
      'result' => 0,
      'status_message' => 'Passed',
      'result_message' => 'Passed',
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => json_format_time(Time.now.utc),
      'duration' => 60,
      'build_url' => 'https://travis-ci.org/svenfuchs/minimal/builds/1',
      'config' => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] },
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'message' => 'the commit message',
      'committed_at' => json_format_time(Time.now.utc - 1.hour),
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'type' => 'push',
    }
  end

  it 'includes the repository' do
    data['repository'].should == {
      'id' => 1,
      'name' => 'minimal',
      'owner_name' => 'svenfuchs',
      'url' => 'http://github.com/svenfuchs/minimal'
    }
  end

  describe 'includes the build matrix' do
    it 'payload' do
      data['matrix'].first.except('log').should == {
        'id' => 1,
        'repository_id' => 1,
        'parent_id' => 1,
        'number' => '2.1',
        'state' => 'finished',
        'started_at' => json_format_time(Time.now.utc - 1.minute),
        'finished_at' => json_format_time(Time.now.utc),
        'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
        'status' => 0,
        'result' => 0,
        'commit' => '62aae5f70ceee39123ef',
        'branch' => 'master',
        'message' => 'the commit message',
        'author_name' => 'Sven Fuchs',
        'author_email' => 'svenfuchs@artweb-design.de',
        'committer_name' => 'Sven Fuchs',
        'committer_email' => 'svenfuchs@artweb-design.de',
        'committed_at' => json_format_time(Time.now.utc - 1.hour),
        'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop'
      }
    end

    it 'given include_logs is true' do
      options.replace :include_logs => true
      data['matrix'].first['log'].should == 'the test log'
    end

    it 'given include_logs is false' do
      options.replace :include_logs => false
      data['matrix'].first['log'].should be_nil
    end

    it 'has a different type for pull requests' do
      build.stubs(:event_type).returns('pull_request')
      data['type'].should == 'pull_request'
    end

    it 'includes the pull request number for pull requests' do
      build.stubs(:event_type).returns('pull_request')
      build.commit.stubs(:pull_request?).returns(true)
      build.commit.stubs(:pull_request_number).returns 1
      data['pull_request_number'].should == 1
    end
  end
end
