require 'spec_helper'

describe Travis::Event::Handler::Worker do
  include Support::Stubs

  describe 'call' do
    let(:handler) { Travis::Event::Handler::Worker.new(:start, test) }
    let(:builds)  { stub('builds', :publish => true) }
    let(:payload) { Travis::Api.data(test, :for => 'worker', :type => 'Job::Test', :version => 'v0') }

    before :each do
      Travis::Amqp::Publisher.stubs(:builds).returns(builds)
    end

    it 'fetches a publisher for the given queue name (routing_key)' do
      Travis::Amqp::Publisher.expects(:builds).with('builds.common').returns(builds)
      handler.call
    end

    it 'publishes the payload to the publisher' do
      builds.expects(:publish).with(payload, :properties => { :type => 'test' })
      handler.call
    end
  end

  describe 'publisher' do
    it 'returns a publisher for "builds.configure" for a configure job' do
      handler = Travis::Event::Handler::Worker.new(:start, configure)
      handler.send(:publisher).routing_key.should == 'builds.configure'
    end

    it 'returns a publisher for "builds.common" for a test job' do
      handler = Travis::Event::Handler::Worker.new(:start, test)
      handler.send(:publisher).routing_key.should == test.queue
    end
  end

  describe 'payload_for' do
    it 'returns Travis::Event::Worker::Job::Configure for a configure job' do
      handler = Travis::Event::Handler::Worker.new(:start, configure)
      handler.send(:payload).should == Travis::Api::V0::Worker::Job::Configure.new(configure).data
    end

    it 'returns Travis::Event::Worker::Job::Test for a test job' do
      handler = Travis::Event::Handler::Worker.new(:start, test)
      handler.send(:payload).should == Travis::Api::V0::Worker::Job::Test.new(test).data
    end
  end
end
