require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::Worker do
  include Support::ActiveRecord

  let(:worker)  { Travis::Notifications::Worker.new }
  let(:payload) { { :the => 'payload' } }

  describe 'notify' do
    let(:job) { Factory(:request).job }

    before :each do
      Travis::Notifications::Worker::Payload.stubs(:for).with(job).returns(payload)
      Travis::Amqp.stubs(:publish)
    end

    it 'generates a payload for the given job' do
      Travis::Notifications::Worker::Payload.stubs(:for).with(job)
      worker.notify(:start, job)
    end

    it 'adds the payload to the given queue' do
      Travis::Amqp.expects(:publish).with('builds.common', payload)
      worker.notify(:start, job)
    end
  end
end
