require 'spec_helper'
require 'support/active_record'
require 'travis/api'

describe Travis::Api::Json::Http::Build do
  include Support::ActiveRecord, Support::Formats

  let(:build) { Factory(:build, :matrix => [test], :config => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] }) }
  let(:test)  { Factory(:test, :config => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' }, :started_at => Time.now.utc, :finished_at => Time.now.utc) }
  let(:data)  { Travis::Api::Json::Http::Build.new(build).data }

  before :each do
    build.request.event_type = 'push'
  end

  it 'build' do
    data.except('matrix').should == {
      'id' => build.id,
      'event_type' => 'push', # on the build api this probably should be just 'pull_request' => true or similar
      'repository_id' => build.repository_id,
      'number' => 2,
      'state' => :created,
      'started_at' => json_format_time(Time.now.utc),
      'finished_at' => json_format_time(Time.now.utc),
      'duration' => nil,
      'config' => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] },
      'status' => 0, # still here for backwards compatibility
      'result' => 0,
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'committed_at' => '2011-11-11T11:11:11Z',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'committer_name' => 'Sven Fuchs',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
    }
  end

  it 'matrix' do
    data['matrix'].first.should == {
      'id' => test.id,
      'number' => '2.1',
      'log' => nil,
      'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
      'started_at' => json_format_time(Time.now.utc),
      'finished_at' => json_format_time(Time.now.utc)
    }
  end
end

