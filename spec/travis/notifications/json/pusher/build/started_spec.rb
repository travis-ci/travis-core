require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe Travis::Notifications::Json::Pusher::Build::Started do
  include Support::ActiveRecord, Support::Formats

  let(:build) { Factory(:build, :matrix => [test], :config => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] }) }
  let(:test)  { Factory(:test, :config => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' }) }
  let(:data)  { Travis::Notifications::Json::Pusher::Build::Started.new(build).data }

  it 'build' do
    data['build'].except('matrix').should == {
      'id' => build.id,
      'repository_id' => build.repository_id,
      'number' => 2,
      'config' => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] },
      'result' => 0,
      'started_at' => json_format_time(Time.now.utc),
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'committed_at' => '2011-11-11T11:11:11Z',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'event_type' => 'push'
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
      'committed_at' => '2011-11-11T11:11:11Z',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop'
    }
  end

  it 'repository' do
    data['repository'].should == {
      'id' => build.repository_id,
      'slug' => 'svenfuchs/minimal',
      'description' => nil,
      'last_build_id' => 2,
      'last_build_number' => '2',
      'last_build_started_at' => json_format_time(Time.now.utc),
      'last_build_finished_at' => json_format_time(Time.now.utc),
      'last_build_duration' => nil,
      'last_build_result' => 0,
      'last_build_language' => nil
    }
  end
end
