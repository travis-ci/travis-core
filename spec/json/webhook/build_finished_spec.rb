require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe 'JSON for webhooks' do
  include Support::ActiveRecord, Support::Formats

  let(:build) { Factory(:build) }

  it 'build:finished' do
    json_for_webhook(build).except('matrix').should == {
      'repository' => {
        'id' => build.repository_id,
        'name' => 'minimal',
        'owner_name' => 'svenfuchs',
        'url' => 'http://github.com/svenfuchs/minimal'
      },
      'id' => build.id,
      'number' => 1,
      'status' => 0,
      'status_message' => 'Pending',
      'started_at' => json_format_time(Time.now.utc),
      'finished_at' => json_format_time(Time.now.utc),
      'duration' => nil,
      'config' => {},
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
end

