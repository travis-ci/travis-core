require 'spec_helper'

describe Travis::Api::V1::Http::Branch do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V1::Http::Branch.new(build).data }
  let(:branch) { build }

  before :each do
    repository.stubs(:last_build_on).returns(branch)
  end

  it 'data' do
    data.should be == {
      'repository_id' => 1,
      'build_id' => 1,
      'commit' => '62aae5f70ceee39123ef',
      'branch' => 'master',
      'message' => 'the commit message',
      'result' => 0,
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'finished_at' => json_format_time(Time.now.utc),
    }
  end
end
