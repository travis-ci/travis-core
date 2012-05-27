require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::V1::Pusher::Job::Log do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::V1::Pusher::Job::Log.new(test, :_log => 'some chars').data }

  it 'data' do
    data.should == {
      'id' => test.id,
      '_log' => 'some chars'
    }
  end
end

