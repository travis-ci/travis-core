require 'spec_helper'
require 'support/formats'
require 'travis/api/support/stubs'

describe Travis::Api::Json::Archive::Build do
  include Support::Formats, Support::Stubs

  let(:data) { Travis::Api::Json::Archive::Build.new(build).data }

  it 'data' do
    data.except('matrix', 'repository').should == {
      'id' => build.id,
      'number' => 2,
      'config' => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] },
      'result' => 0,
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => json_format_time(Time.now.utc),
      'duration' => 60,
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'committed_at' => json_format_time(Time.now.utc - 1.hour),
    }
  end

  it 'matrix' do
    data['matrix'].first.should == {
      'id' => test.id,
      'number' => '2.1',
      'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => json_format_time(Time.now.utc),
      'log' => 'the test log'
    }
  end

  it 'repository' do
    data['repository'].should == {
      'id' => build.repository_id,
      'slug' => 'svenfuchs/minimal',
    }
  end
end
