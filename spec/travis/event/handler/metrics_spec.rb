require 'spec_helper'

describe Travis::Event::Handler::Metrics do
  include Travis::Testing::Stubs

  before do
    handler.stubs(:handle => true, :handle? => true)
    Travis::Event.stubs(:subscribers).returns [:metrics]
    Travis::Instrumentation.stubs(:meter)
  end

  describe 'subscription' do
    let(:handler) { Travis::Event::Handler::Metrics.any_instance }

    it 'build:started does not notify' do
      handler.expects(:notify).never
      Travis::Event.dispatch('build:started', build)
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
    let(:handler)     {  }
    let(:created_at)  { Time.now.utc - 180 }
    let(:started_at)  { Time.now.utc - 120 }
    let(:finished_at) { Time.now.utc - 60 }

    before :each do
      test.stubs(:created_at => created_at, :started_at => started_at, :finished_at => finished_at)
    end

    def notify(event, object)
      Travis::Event::Handler::Metrics.new(event, object).notify
    end

    it 'job:test:started notifies' do
      Travis::Instrumentation.expects(:meter).with('job.queue.wait_time', :started_at => created_at, :finished_at => started_at)
      notify('job:test:started', test)
    end

    it 'job:test:finished notifies' do
      Travis::Instrumentation.expects(:meter).with('job.duration', :started_at => started_at, :finished_at => finished_at)
      notify('job:test:finished', test)
    end
  end
end

