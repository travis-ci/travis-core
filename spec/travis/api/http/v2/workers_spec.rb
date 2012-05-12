require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Http::V2::Workers do
  include Support::Formats, Support::Stubs

  let(:data) { Travis::Api::Http::V2::Workers.new([worker]).data }

  before(:each) do
    Time.stubs(:now).returns(Time.utc(2011, 11, 11, 11, 11, 11))
  end

  it 'workers' do
    data['workers'].first.should == {
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
