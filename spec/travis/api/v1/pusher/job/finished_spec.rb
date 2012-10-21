require 'spec_helper'

describe Travis::Api::V1::Pusher::Job::Finished do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V1::Pusher::Job::Finished.new(test).data }

  it 'data' do
    data.should == {
      'id' => test.id,
      'build_id' => test.source_id,
      'repository_id' => test.repository_id,
      'finished_at' => json_format_time(Time.now.utc),
      'result' => 0,
      'state' => 'finished'
    }
  end
end

