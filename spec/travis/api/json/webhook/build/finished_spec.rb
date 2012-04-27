require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe Travis::Api::Json::Webhook::Build::Finished do
  include Support::ActiveRecord, Support::Formats

  let(:build) { Factory(:build, :matrix => [test], :config => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] }) }
  let(:test)  { Factory(:test, :config => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' }, :state => :created) }
  let(:data)  { Travis::Api::Json::Webhook::Build::Finished.new(build).data }

  it 'data' do
    data.except('repository', 'matrix').should == {
      'id' => build.id,
      'number' => 2,
      'status' => 0,
      'status_message' => 'Pending',
      'started_at' => json_format_time(Time.now.utc),
      'finished_at' => json_format_time(Time.now.utc),
      'duration' => nil,
      'config' => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] },
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'message' => 'the commit message',
      'committed_at' => '2011-11-11T11:11:11Z',
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
    }
  end

  it 'repository' do
    data['repository'].should == {
      'id' => build.repository_id,
      'name' => 'minimal',
      'owner_name' => 'svenfuchs',
      'url' => 'http://github.com/svenfuchs/minimal'
    }
  end

  it 'matrix' do
    data['matrix'].first.should == {
      'id' => test.id,
      'repository_id' => test.repository_id,
      'parent_id' => test.source_id,
      'number' => '2.1',
      'state' => :created,
      'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
      'status' => nil,
      'result' => nil,
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'committed_at' => '2011-11-11T11:11:11Z',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'log' => '',
    }
  end
end
