require 'spec_helper'

describe Travis::Event::Handler::Metrics do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Event::Handler::Metrics }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  describe 'subscription' do
    let(:handler) { subject.any_instance }

    before :each do
      Travis::Event.stubs(:subscribers).returns [:metrics]
      handler.stubs(:handle => true, :handle? => true)
      Travis::Api.stubs(:data).returns(stub('data'))
    end

    it 'build:started does not notify' do
      handler.expects(:notify).never
      Travis::Event.dispatch('build:started', test)
    end

    it 'job:test:started notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('job:test:started', test)
    end

    it 'job:test:finished notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('job:test:finished', test)
    end
  end

  describe 'metrics' do
    let(:created_at)  { Time.now.utc - 180 }
    let(:started_at)  { Time.now.utc - 120 }
    let(:finished_at) { Time.now.utc - 60 }

    before :each do
      test.stubs(:created_at => created_at, :started_at => started_at, :finished_at => finished_at)
      Travis::Instrumentation.stubs(:meter)
    end

    def notify(event, object)
      subject.notify(event, object)
    end

    describe 'job:test:started' do
      it 'meters on job.queue.wait_time' do
        Travis::Instrumentation.expects(:meter).with('job.queue.wait_time', :started_at => created_at, :finished_at => started_at)
        notify('job:test:started', test)
      end

      it 'meters on job.queue.builds-common.wait_time' do
        Travis::Instrumentation.expects(:meter).with('job.queue.wait_time.builds-common', :started_at => created_at, :finished_at => started_at)
        notify('job:test:started', test)
      end
    end

    describe 'job:test:finished' do
      it 'meters on job.duration' do
        Travis::Instrumentation.expects(:meter).with('job.duration', :started_at => started_at, :finished_at => finished_at)
        notify('job:test:finished', test)
      end

      it 'meters on job.duration' do
        Travis::Instrumentation.expects(:meter).with('job.duration.builds-common', :started_at => started_at, :finished_at => finished_at)
        notify('job:test:finished', test)
      end
    end
  end
end

