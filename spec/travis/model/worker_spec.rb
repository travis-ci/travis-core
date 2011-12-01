require 'spec_helper'
require 'support/active_record'

describe Worker do
  include Support::ActiveRecord

  let(:worker)    { Factory(:worker, :payload => QUEUE_PAYLOADS['job:test:1']) }

  describe 'full_name' do
    it 'returns a name consisting of host and name' do
      worker.full_name.should == 'ruby-1.worker.travis-ci.org:ruby-1'
    end
  end

  describe 'serialization' do
    it 'serializes the payload' do
      worker.reload.payload.should == QUEUE_PAYLOADS['job:test:1']
    end
  end
end

