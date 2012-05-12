require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Http::V1::Builds do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::Http::V1::Builds.new([build]).data }

  it 'builds' do
    data.first.should == {
      'id' => build.id,
      'event_type' => 'push', # on the build api this probably should be just 'pull_request' => true or similar
      'repository_id' => build.repository_id,
      'number' => 2,
      'state' => 'finished',
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => json_format_time(Time.now.utc),
      'duration' => 60,
      'result' => 0,
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message'
    }
  end
end

