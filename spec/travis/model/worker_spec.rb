require 'spec_helper'

describe Worker do
  include Support::ActiveRecord

  let(:worker)    { Factory(:worker, :payload => QUEUE_PAYLOADS['job:test:1']) }

  it 'saves full_name on save' do
    worker.name = 'ruby-44'
    worker.save
    worker.full_name.should == 'ruby-1.worker.travis-ci.org:ruby-44'
  end

  describe 'serialization' do
    it 'serializes the payload' do
      worker.reload.payload.should == QUEUE_PAYLOADS['job:test:1']
    end
  end
end

