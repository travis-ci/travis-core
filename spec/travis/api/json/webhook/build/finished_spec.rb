require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Json::Webhook::Build::Finished do
  include Support::Stubs, Support::Formats

  let(:data)  { Travis::Api::Json::Webhook::Build::Finished.new(build).data }

  it 'data' do
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
    }
  end

  it 'repository' do
    data['repository'].should == {
      'id' => 1,
      'name' => 'minimal',
      'owner_name' => 'svenfuchs',
      'url' => 'http://github.com/svenfuchs/minimal'
    }
  end

  it 'matrix' do
    data['matrix'].first.should == {
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
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'log' => 'the test log',
    }
  end
end
