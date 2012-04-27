require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe Travis::Api::Json::Pusher::Worker do
  include Support::ActiveRecord, Support::Formats

  let(:worker) { Factory(:worker) }
  let(:data)   { Travis::Api::Json::Pusher::Worker.new(worker).data }

  it 'data' do
    data.should == {
      'id' => worker.id,
      'host' => 'ruby-1.worker.travis-ci.org',
      'name' => 'ruby-1',
      'state' => :created,
      'last_error' => nil,
      'payload' => nil
    }
  end
end


