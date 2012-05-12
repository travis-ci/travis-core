require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Json::Http::V1::Branches do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::Json::Http::V1::Branches.new(repository).data }
  let(:branches) { [build] }

  before :each do
    repository.stubs(:last_finished_builds_by_branches).returns(branches)
  end

  it 'data' do
    data.should == [{
      'repository_id' => 1,
      'build_id' => 1,
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message',
      'result' => 0,
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => json_format_time(Time.now.utc),
    }]
  end
end
