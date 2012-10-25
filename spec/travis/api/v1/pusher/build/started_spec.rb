require 'spec_helper'

describe Travis::Api::V1::Pusher::Build::Started do
  include Travis::Testing::Stubs, Support::Formats

  let(:data)  { Travis::Api::V1::Pusher::Build::Started.new(build).data }

  it 'build' do
    data['build'].except('matrix').should == {
      'id' => build.id,
      'repository_id' => build.repository_id,
      'number' => 2,
      'config' => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] },
      'result' => nil,
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'job_ids' => [1, 2],
      'message' => 'the commit message',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'committed_at' => json_format_time(Time.now.utc - 1.hour),
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'event_type' => 'push',
      'state' => 'finished',
      'duration' => 60,
      'finished_at' => json_format_time(Time.now.utc)
    }
  end

  it 'matrix' do
    data['build']['matrix'].first.should == {
      'id' => test.id,
      'repository_id' => build.repository_id,
      'parent_id' => test.source_id,
      'number' => '2.1',
      'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'committed_at' => json_format_time(Time.now.utc - 1.hour),
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'allow_failure' => false
    }
  end

  it 'repository' do
    data['repository'].should == {
      'id' => build.repository_id,
      'slug' => 'svenfuchs/minimal',
      'description' => 'the repo description',
      'last_build_id' => 1,
      'last_build_number' => 2,
      'last_build_started_at' => json_format_time(Time.now.utc - 1.minute),
      'last_build_finished_at' => json_format_time(Time.now.utc),
      'last_build_duration' => 60,
      'last_build_status' => 0,
      'last_build_result' => 0,
      'last_build_language' => 'ruby'
    }
  end
end
