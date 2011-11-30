require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::Worker do
  include Support::ActiveRecord

  let(:worker)    { Travis::Notifications::Worker.new }
  let(:publisher) { stub('publisher', :publish => nil) }
  let(:payload)   { { :the => 'payload' } }

  describe 'notify' do
    let(:job) { Factory(:request).job }

    before :each do
      Travis::Amqp::Publisher.stubs(:builds).returns(publisher)
      Travis::Notifications::Worker::Payload.stubs(:for).with(job).returns(payload)
    end

    it 'generates a payload for the given job' do
      Travis::Notifications::Worker::Payload.stubs(:for).with(job)
      worker.notify(:start, job)
    end

    it 'fetches a publisher for the given queue name (routing_key)' do
      Travis::Amqp::Publisher.expects(:builds).with('builds.common').returns(publisher)
      worker.notify(:start, job)
    end

    it 'publishes the payload to the publisher' do
      publisher.expects(:publish).with(payload)
      worker.notify(:start, job)
    end
  end
end
