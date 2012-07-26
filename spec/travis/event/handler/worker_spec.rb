require 'spec_helper'

describe Travis::Event::Handler::Worker do
  include Travis::Testing::Stubs

  let(:handler)   { Travis::Event::Handler::Worker.new(:start, worker) }
  let(:payload)   { Travis::Api.data(test, :for => 'worker', :type => 'Job::Test', :version => 'v0') }
  let(:publisher) { stub('publisher', :publish => true) }

  before :each do
    Travis::Event.stubs(:subscribers).returns [:worker]
    Travis::Amqp::Publisher.stubs(:builds).returns(publisher)
    Job.stubs(:queued).returns([test])
    test.stubs(:enqueue)
  end

  describe 'notify' do
    it 'fetches a publisher for the given queue name (routing_key)' do
      Travis::Amqp::Publisher.expects(:builds).with('builds.common').returns(publisher)
      handler.notify
    end

    it 'publishes the payload to the publisher' do
      publisher.expects(:publish).with(payload, :properties => { :type => 'test' })
      handler.notify
    end
  end

  describe 'payload_for' do
    it 'returns Travis::Event::Worker::Job::Test for a test job' do
      handler = Travis::Event::Handler::Worker.new(:start, test)
      handler.send(:payload).should == Travis::Api::V0::Worker::Job::Test.new(test).data
    end
  end

  describe 'instrumentation' do
    before :each do
      handler.stubs(:handle)
      Travis::Event.stubs(:subscribers).returns [:worker]
    end

    it 'instruments with "travis.event.handler.worker.notify:*"' do
      ActiveSupport::Notifications.stubs(:publish)
      ActiveSupport::Notifications.expects(:publish).with do |event, data|
        event =~ /travis.event.handler.worker.notify/ && data[:target].is_a?(Travis::Event::Handler::Worker)
      end
      Travis::Event.dispatch('worker:ready', test)
    end

    it 'meters on "travis.event.handler.worker.notify:completed"' do
      Metriks.expects(:timer).with('v1.travis.event.handler.worker.notify:completed').returns(stub('timer', :update => true))
      handler.notify
    end
  end
end
