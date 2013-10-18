require 'spec_helper'

describe Travis::Api::V0::Event::Build do
  include Travis::Testing::Stubs, Support::Formats

  let(:build) { stub_build(owner: owner) }
  let(:data) { Travis::Api::V0::Event::Build.new(build).data }

  let(:owner) {
    OpenStruct.new(avatar_url: 'https://github.com/roidrage.png')
  }

  before do
  end

  it 'includes the build data' do
    data['build'].should == {
      'id' => 1,
      'repository_id' => 1,
      'commit_id' => 1,
      'job_ids' => [1, 2],
      'number' => 2,
      'pull_request' => false,
      'config' => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] },
      'state' => 'passed',
      'previous_state' => 'passed',
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => json_format_time(Time.now.utc),
      'duration' => 60
    }
  end

  it 'includes the repository data' do
    data['repository']['owner_avatar_url'].should == 'https://github.com/roidrage.png'
  end

  it 'includes the commit' do
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
      'author_email' => 'svenfuchs@artweb-design.de',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
    }
  end

  it "doesn't include the source key" do
    build.config[:source_key] = '1234'
    data['build']['config']['source_key'].should == nil
  end
end
