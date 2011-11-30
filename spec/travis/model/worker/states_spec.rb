require 'spec_helper'
require 'hashr'

class WorkerMock
  class << self
    def name; 'Worker'; end
    def after_create; end
  end

  include Worker::States

  attr_accessor :state
  def update_attributes!(*); end
end

describe Worker::States do
  let(:job) { WorkerMock.new }

  describe 'ping' do
    let(:data) { Hashr.new(:state => :started) }

    it 'sets the state' do
      job.expects(:update_attributes!).with(:state => :started, :last_seen_at => Time.now.utc)
      job.ping(data)
    end

    it 'notifies observers' do
      Travis::Notifications.expects(:dispatch).with('worker:updated', job, data)
      job.ping(data)
    end
  end
end

