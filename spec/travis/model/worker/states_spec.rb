require 'spec_helper'

class WorkerMock
  class << self
    def name; 'Worker'; end
    def after_create(*); end
  end

  include Worker::States

  attr_accessor :state
  def save!; end
end

describe Worker::States do
  let(:job) { WorkerMock.new }

  describe 'events' do
    describe 'starting the worker' do
      let(:data) { WORKER_PAYLOADS['worker:started'] }

      it 'sets the state to :started' do
        job.start(data)
        job.state.should == :started
      end

      it 'notifies observers' do
        Travis::Notifications.expects(:dispatch).with('worker:started', job, data)
        job.start(data)
      end
    end
  end
end

