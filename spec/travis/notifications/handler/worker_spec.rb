require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::Handler::Worker do
  include Support::ActiveRecord

  let(:worker)    { Travis::Notifications::Handler::Worker.new }
  let(:payload)   { { :the => 'payload' } }
  let(:builds)    { stub('builds', :publish => nil) }
  let(:repo)      { Factory(:repository) }
  let(:commit)    { Factory(:commit, :repository => repo) }
  let(:configure) { Factory(:configure, :commit => commit) }
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
      builds.expects(:publish).with(payload, :properties => { :type => 'test' })
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

  describe 'payload_for' do
    it 'returns Travis::Notifications::Worker::Job::Configure for a configure job' do
      worker.send(:payload_for, configure).should == Travis::Api::V0::Worker::Job::Configure.new(configure).data
    end

    it 'returns Travis::Notifications::Worker::Job::Test for a test job' do
      worker.send(:payload_for, test).should == Travis::Api::V0::Worker::Job::Test.new(test).data
    end
  end
end
