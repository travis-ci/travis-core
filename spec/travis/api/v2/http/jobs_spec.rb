require 'spec_helper'

describe Travis::Api::V2::Http::Jobs do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V2::Http::Jobs.new([test]).data }

  it 'jobs' do
    data['jobs'].first.should == {
      'id' => 1,
      'repository_id' => 1,
      'build_id' => 1,
      'commit_id' => 1,
      'log_id' => 1,
      'number' => '2.1',
      'state' => 'finished',
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => json_format_time(Time.now.utc),
      'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
      'result' => 0,
      'queue' => 'builds.common',
      'allow_failure' => false,
      'tags' => 'tag-a,tag-b'
    }
  end

  it 'commits' do
    data['commits'].first.should == {
      'id' => 1,
      'sha' => '62aae5f70ceee39123ef',
      'message' => 'the commit message',
      'branch' => 'master',
      'message' => 'the commit message',
      'committed_at' => json_format_time(Time.now.utc - 1.hour),
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
    }
  end
end

describe 'Travis::Api::V2::Http::Jobs using Travis::Services::Jobs::FindAll' do
  include Support::ActiveRecord

  let(:jobs) { Travis::Services::Jobs::FindAll.new(nil).run }
  let(:data) { Travis::Api::V2::Http::Jobs.new(jobs).data }

  before :each do
    3.times { Factory(:test) }
  end

  it 'queries' do
    lambda { data }.should issue_queries(3)
  end
end

