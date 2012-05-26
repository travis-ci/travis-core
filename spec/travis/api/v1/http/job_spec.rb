require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::V1::Http::Job do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::V1::Http::Job.new(test).data }

  it 'data' do
    data.should == {
      'id' => test.id,
      'repository_id' => test.repository_id,
      'number' => '2.1',
      'state' => 'finished',
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => json_format_time(Time.now.utc),
      'config' => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
      'log' => 'the test log',
      'status' => 0, # still here for backwards compatibility
      'result' => 0,
      'build_id' => test.source_id,
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message',
      'committed_at' => json_format_time(Time.now.utc - 1.hour),
      'committer_name' => 'Sven Fuchs',
      'committer_email' => 'svenfuchs@artweb-design.de',
      'author_name' => 'Sven Fuchs',
      'author_email' => 'svenfuchs@artweb-design.de',
      'compare_url' => 'https://github.com/svenfuchs/minimal/compare/master...develop',
      'worker' => 'ruby3.worker.travis-ci.org:travis-ruby-4',
      'sponsor' => { 'name' => 'Railslove', 'url' => 'http://railslove.de' }
    }
  end
end
