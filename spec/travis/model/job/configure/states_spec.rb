require 'spec_helper'

class ConfigureMock
  include Module.new { def update_attributes(*); end }

  class << self
    def name; 'Job::Configure'; end
    def after_create(*); end
    def after_commit(*); end
  end

  include Job::Configure::States

  attr_accessor :state, :config, :result, :finished_at
  def source; @source ||= stub('request', :start => nil, :configure! => nil, :state => nil, :state= => nil) end
  def save!; end
end

describe Job::Configure::States do
  let(:job)    { ConfigureMock.new }
  let(:config) { { :rvm => 'rbx' } }

  describe 'events' do
    describe 'starting the job' do
      it 'sets the state to :started' do
        job.start
        job.state.should == :started
      end

      it 'propagates the event to the source' do
        job.source.expects(:start)
        job.start
      end

      it 'notifies observers' do
        Travis::Event.expects(:dispatch).with('job:configure:started', job)
        job.start!
      end
    end

    describe 'finishing the job' do
      it 'sets the state to :finished' do
        job.finish(config)
        job.state.should == :finished
      end

      it 'configures the source' do
        job.source.expects(:configure!).with(config)
        job.finish(config)
      end

      it 'notifies observers' do
        data = { :result => 0, :config => config, :finished_at => Time.now.utc }

        Travis::Event.expects(:dispatch).with('job:configure:started', job)
        Travis::Event.expects(:dispatch).with('job:configure:finished', job, data)

        # TODO
        # Travis::Event.expects(:dispatch).with('request:configured', job, config) # not implemented
        # Travis::Event.expects(:dispatch).with('job:test:created', instance_of(Job::Test)).times(2)

        job.start!
        job.finish!(data)
      end
    end

    describe 'update_attributes' do
      describe 'given finishing attributes' do
        let(:attributes) { { :config => { :rvm => 'rbx' }, :result => 0 } }

        it 'extracts finishing attributes' do
          job.update_attributes(attributes)
        end

        it 'updates the job with the given attributes' do
          job.expects(:update_attributes).with(attributes)
          job.update_attributes(attributes)
        end

        it 'finishes the job' do
          job.update_attributes(attributes)
          job.state.should == :finished
        end
      end
    end
  end
end
