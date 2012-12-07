require 'spec_helper'

describe Job::Test do
  include Support::ActiveRecord

  let(:job) { Factory(:test) }

  before :each do
    Travis::Event.stubs(:dispatch)
  end

  describe 'events' do
    describe 'starting the job' do
      let(:data) { WORKER_PAYLOADS['job:test:started'] }

      it 'sets the state to :started' do
        job.start(data)
        job.state.should == :started
      end

      it 'sets the worker from the payload' do
        job.start(data)
        job.worker.should == 'ruby3.worker.travis-ci.org:travis-ruby-4'
      end

      it "resets the log artifact's content" do
        job.log.expects(:update_attributes!).with(:content => '')
        job.start(data)
      end

      it 'notifies observers' do
        Travis::Event.expects(:dispatch).with('job:test:started', job, data)
        job.start(data)
      end

      it 'propagates the event to the source' do
        job.source.expects(:start)
        job.start(data)
      end
    end

    describe 'finishing the job' do
      let(:data) { WORKER_PAYLOADS['job:test:finished'] }

      it 'sets the state to the given result state (legacy: passing result=[0|1])' do
        job.finish(data.merge('result' => 0, 'state' => 'finished'))
        job.state.should == 'passed'
      end

      it 'sets the state to the given result state' do
        job.finish(data)
        job.state.should == 'passed'
      end

      it 'notifies observers' do
        Travis::Event.expects(:dispatch).with('job:test:finished', job, data)
        job.finish(data)
      end

      it 'propagates the event to the source' do
        job.source.expects(:finish).with(data)
        job.finish(data)
      end
    end
  end
end
