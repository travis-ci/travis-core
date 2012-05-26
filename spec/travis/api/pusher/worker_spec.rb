require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Pusher::Worker do
  include Support::Stubs, Support::Formats

  let(:data)   { Travis::Api::Pusher::Worker.new(worker).data }

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


