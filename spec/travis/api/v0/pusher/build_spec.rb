require 'spec_helper'

describe Travis::Api::V0::Pusher::Build do
  include Travis::Testing::Stubs, Support::Formats

  let(:repo)  { stub_repo(last_build_state: :started, last_build_duration: nil, last_build_finished_at: nil) }
  let(:job)   { stub_test(state: :started, finished_at: nil, finished?: false) }
  let(:build) { stub_build(repository: repo, event_type: 'pull_request',  state: :started, finished_at: nil, matrix: [job], finished?: false) }
  let(:serializer) {
    serializer = Travis::Api::V0::Pusher::Build.new(build)
    serializer.stubs(:last_build_on_default_branch_id).returns(1)
    serializer
  }
  let(:data)  { serializer.data }

  it 'build' do
    data['build'].except('matrix').should == {
      'id' => build.id,
      'repository_id' => build.repository_id,
      'number' => 2,
      'state' => 'started',
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => nil,
      'duration' => 60,
      'commit' => '62aae5f70ceee39123ef',
      'commit_id' => 1,
      'branch' => 'master',
      'job_ids' => [1],
      'message' => 'the commit message',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'committed_at' => json_format_time(Time.now.utc - 1.hour),
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'event_type' => 'pull_request',
      'pull_request' => false,
      'pull_request_title' => nil,
      'pull_request_number' => nil,
      'job_ids' => [1, 2],
      'is_on_default_branch' => true
    }
  end

  it 'repository' do
    data['repository'].should == {
      'id' => build.repository_id,
      'slug' => 'svenfuchs/minimal',
      'private' => false,
      'description' => 'the repo description',
      'last_build_id' => 1,
      'last_build_number' => 2,
      'last_build_started_at' => json_format_time(Time.now.utc - 1.minute),
      'last_build_finished_at' => nil,
      'last_build_duration' => nil,
      'last_build_state' => 'started',
      'last_build_language' => nil,
      'github_language' => 'ruby',
      'default_branch' => {
        'name' => 'master',
        'last_build_id' => 1
      }
    }
  end
end
