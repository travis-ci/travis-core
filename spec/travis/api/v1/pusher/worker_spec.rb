require 'spec_helper'

describe Travis::Api::V1::Pusher::Worker do
  include Travis::Testing::Stubs, Support::Formats

  let(:data)   { Travis::Api::V1::Pusher::Worker.new(worker).data }

  it 'data' do
    data.should == {
      'id' => 1,
      'host' => 'ruby-1.worker.travis-ci.org',
      'name' => 'ruby-1',
      'state' => 'created',
      'last_error' => nil,
      'payload' => nil,
      'last_seen_at' => json_format_time(Time.now.utc)
    }
  end
end


