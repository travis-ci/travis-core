require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::V1::Pusher::Job::Finished do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::V1::Pusher::Job::Finished.new(test).data }

  it 'data' do
    data.should == {
      'id' => test.id,
      'build_id' => test.source_id,
      'finished_at' => json_format_time(Time.now.utc),
      'result' => 0
    }
  end
end

