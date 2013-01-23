require 'spec_helper'

describe Travis::Api::V1::Http::Workers do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V1::Http::Workers.new([worker]).data }

  before(:each) do
    Time.stubs(:now).returns(Time.utc(2011, 11, 11, 11, 11, 11))
  end

  it 'workers' do
    data.first.should == {
      'id' => 1,
      'name' => 'ruby-1',
      'host' => 'ruby-1.worker.travis-ci.org',
      'state' => 'created',
      'payload' => nil
    }
  end
end
