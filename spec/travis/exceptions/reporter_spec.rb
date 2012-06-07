require 'spec_helper'

describe Travis::Exceptions::Reporter do
  let(:reporter) { Travis::Exceptions::Reporter.new }

  before :each do
    Travis::Exceptions::Reporter.queue = Queue.new
    Hubble.config['backend_name'] = 'memory'
    Hubble.raise_errors = false
  end

  it "setup a queue" do
    reporter.queue.should be_instance_of(Queue)
  end

  it "should loop in a separate thread" do
    reporter.expects(:error_loop)
    reporter.run
    reporter.thread.join
  end

  it "should report an error when something is on the queue" do
    Hubble.expects(:report)
    reporter.queue.push(StandardError.new)
    reporter.pop
  end

  it "should not raise an error when pop fails" do
    reporter.queue.expects(:pop).raises(StandardError.new)
    expect { reporter.pop }.to_not raise_error
  end

  it "should allow pushing an error on the queue" do
    error = StandardError.new
    Travis::Exceptions::Reporter.enqueue(error)
    reporter.queue.pop.should == error
  end

  it "should add custom metadata to hubble" do
    exception = Class.new(StandardError) do
      def event
        'configure'
      end

      def payload
        { 'type' => 'pull_request' }
      end
    end.new

    reporter.handle(exception)

    reported = Hubble.backend.reports.first
    reported['payload'].should == {'type' => 'pull_request'}.inspect
    reported['event'].should == 'configure'
  end

  it "should add the travis environment to hubble" do
    exception = StandardError.new
    reporter.handle(exception)
    reported = Hubble.backend.reports.first
    reported["env"].should == Travis.env
  end
end

