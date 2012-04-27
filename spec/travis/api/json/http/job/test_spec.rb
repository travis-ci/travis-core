require 'spec_helper'
require 'support/active_record'
require 'travis/api'

describe Travis::Api::Json::Http::Job::Test do
  include Support::ActiveRecord, Support::Formats

  let(:test)   { Factory(:test, :config => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' }, :started_at => Time.now.utc, :finished_at => Time.now.utc) }
  let(:data)   { Travis::Api::Json::Http::Job::Test.new(test).data }

  it 'data' do
    data.should == {
      'id' => test.id,
      'repository_id' => test.repository_id,
      'number' => '2.1',
      'state' => :created,
      'started_at' => json_format_time(Time.now.utc),
      'finished_at' => json_format_time(Time.now.utc),
      'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
      'log' => nil,
      'status' => nil, # still here for backwards compatibility
      'result' => nil,
      'build_id' => test.source_id,
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message',
      'committed_at' => '2011-11-11T11:11:11Z',
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'worker' => '',
      'sponsor' => {}
    }
  end
end
