require 'spec_helper'

describe Travis::Api::V1::Pusher::Build::Finished do
  include Travis::Testing::Stubs, Support::Formats

  let(:data)  { Travis::Api::V1::Pusher::Build::Finished.new(build).data }

  it 'build' do
    data['build'].should == {
      'id' => build.id,
      'number' => build.number,
      'state' => 'passed',
      'result' => 0,
      'finished_at' => json_format_time(build.finished_at),
      'duration' => 60,
      'author_email' => 'svenfuchs@artweb-design.de',
      'author_name' => 'Sven Fuchs',
      'branch' => 'master',
      'commit' => '62aae5f70ceee39123ef',
      'commit_id' => 1,
      'committed_at' => json_format_time(build.commit.committed_at),
      'committer_email' => 'svenfuchs@artweb-design.de',
      'committer_name' => 'Sven Fuchs',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'event_type' => 'push',
      'job_ids' => [1, 2],
      'message' => 'the commit message',
      'repository_id' => 1,
      'started_at' => json_format_time(build.started_at),
    }
  end

  it 'repository' do
    data['repository'].should == {
      'id' => build.repository_id,
      'slug' => 'svenfuchs/minimal',
      'last_build_id' => 1,
      'last_build_number' => 2,
      'last_build_state' => 'passed',
      'last_build_result' => 0,
      'last_build_started_at' => json_format_time(Time.now.utc - 1.minute),
      'last_build_finished_at' => json_format_time(Time.now.utc),
      'last_build_duration' => 60,
      'last_build_language' => nil,
      'description' => 'the repo description',
    }
  end
end
