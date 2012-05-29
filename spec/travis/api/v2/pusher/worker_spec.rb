require 'spec_helper'

describe Travis::Api::V2::Pusher::Worker do
  include Support::Stubs

  let(:data)   { Travis::Api::V2::Pusher::Worker.new(worker).data }

  it 'data' do
    data.should == {
      'worker' => {
        'id' => 1,
        'host' => 'ruby-1.worker.travis-ci.org',
        'name' => 'ruby-1',
        'state' => 'created',
        'last_error' => nil,
        'payload' => nil
      }
    }
  end
end


