require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Pusher::Job::Log do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::Pusher::Job::Log.new(test).data }

  it 'data' do
    data.should == {
      'id' => test.id
    }
  end
end

