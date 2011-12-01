require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::Worker do
  include Support::ActiveRecord

  let(:worker)    { Travis::Notifications::Worker.new }
  let(:payload)   { { :the => 'payload' } }
  let(:configure) { stub('configure', :publish => nil) }
  let(:builds)    { stub('builds', :publish => nil) }
  let(:job)       { Factory(:test) }

  describe 'notify' do
    before :each do
      Travis::Amqp::Publisher.stubs(:configure).returns(configure)
      Travis::Amqp::Publisher.stubs(:builds).returns(builds)
      Travis::Notifications::Worker::Payload.stubs(:for).with(job).returns(payload)
    end

    it 'generates a payload for the given job' do
      Travis::Notifications::Worker::Payload.stubs(:for).with(job)
      worker.notify(:start, job)
    end

    it 'fetches a publisher for the given queue name (routing_key)' do
      Travis::Amqp::Publisher.expects(:builds).with('builds.common').returns(builds)
      worker.notify(:start, job)
    end

    it 'publishes the payload to the publisher' do
      builds.expects(:publish).with(payload)
      worker.notify(:start, job)
    end
  end

  describe 'publisher_for' do
    it 'returns a publisher for "builds.configure" for a configure job' do
      worker.send(:publisher_for, Factory(:configure)).routing_key.should == 'builds.configure'
    end

    it 'returns a publisher for "builds.common" for a test job' do
      worker.send(:publisher_for, job).routing_key.should == job.queue
    end
  end
end
