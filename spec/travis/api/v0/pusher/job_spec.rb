require 'spec_helper'

describe Travis::Api::V0::Pusher::Job::Started do
  include Travis::Testing::Stubs, Support::Formats

  let(:test) { stub_test(state: :started, finished_at: nil, finished?: false) }
  let(:data) { Travis::Api::V0::Pusher::Job::Started.new(test).data }

  it 'data' do
    data.except('commit').should == {
      'id' => 1,
      'build_id' => 1,
      'repository_id' => 1,
      'repository_slug' => 'svenfuchs/minimal',
      'repository_private' => false,
      'number' => '2.1',
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => nil,
      'annotation_ids' => [1],
      'state' => 'started',
      'queue' => 'builds.linux',
      'log_id' => 1,
      'commit_id' => 1,
      'allow_failure' => false
    }
  end

  it 'should return commit data' do
    data['commit'].should == {
      'id' => 1,
      'sha' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'committed_at' => json_format_time(Time.now.utc - 1.hour),
      'committer_email' => 'svenfuchs@artweb-design.de',
      'committer_name' => 'Sven Fuchs',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de'
    }
  end
end

