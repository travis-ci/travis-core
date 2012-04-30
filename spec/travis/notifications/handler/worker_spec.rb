require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::Handler::Worker do
  include Support::ActiveRecord

  let(:worker)    { Travis::Notifications::Handler::Worker.new }
  let(:payload)   { { :the => 'payload' } }
  let(:builds)    { stub('builds', :publish => nil) }
  let(:configure) { Factory(:configure) }
  let(:test)      { Factory(:test) }

  describe 'notify' do
    before :each do
      Travis::Amqp::Publisher.stubs(:configure).returns(configure)
      Travis::Amqp::Publisher.stubs(:builds).returns(builds)
    end

    it 'fetches a publisher for the given queue name (routing_key)' do
      Travis::Amqp::Publisher.expects(:builds).with('builds.common').returns(builds)
      worker.notify(:start, test)
    end

    it 'publishes the payload to the publisher' do
      worker.stubs(:payload_for).with(test).returns(payload)
      builds.expects(:publish).with(payload, :properties => { :type => type })
      worker.notify(:start, test)
    end
  end

  describe 'publisher_for' do
    it 'returns a publisher for "builds.configure" for a configure job' do
      worker.send(:publisher_for, configure).routing_key.should == 'builds.configure'
    end

    it 'returns a publisher for "builds.common" for a test job' do
      worker.send(:publisher_for, test).routing_key.should == test.queue
    end
  end

  describe 'renderer_for' do
    it 'returns Travis::Notifications::Json::Worker::Job::Configure for a configure job' do
      worker.send(:renderer_for, configure).should == Travis::Api::Json::Worker::Job::Configure
    end

    it 'returns Travis::Notifications::Json::Worker::Job::Test for a test job' do
      worker.send(:renderer_for, test).should == Travis::Api::Json::Worker::Job::Test
    end
  end
end
