require 'spec_helper'

describe Travis::Api::V1::Pusher::Job::Log do
  include Support::Stubs

  let(:data) { Travis::Api::V1::Pusher::Job::Log.new(test, :_log => 'some chars').data }

  it 'data' do
    data.should == {
      'id' => test.id,
      '_log' => 'some chars'
    }
  end
end

