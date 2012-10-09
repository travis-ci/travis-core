require 'spec_helper'

describe Travis::Api::V2::Http::Worker do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V2::Http::Worker.new(worker).data }

  before(:each) do
    Time.stubs(:now).returns(Time.utc(2011, 11, 11, 11, 11, 11))
  end

  it 'workers' do
    data['worker'].should == {
      'id' => 1,
      'name' => 'ruby-1',
      'host' => 'ruby-1.worker.travis-ci.org',
      'state' => 'created',
      'last_seen_at' => json_format_time(Time.now.utc),
      'payload' => nil,
      'last_error' => nil
    }
  end
end
