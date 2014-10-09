require 'spec_helper'

describe Travis::Enqueue::Services::EnqueueJobs do
  include Travis::Testing::Stubs
  include Support::ActiveRecord

  let(:service) { described_class.new }

  before :each do
    Travis::Features.enable_for_all(:job_queueing)
  end

  describe 'disabled?' do
    it 'enqueues if the feature :job_queueing is not deactivated (default)' do
      Travis::Features.redis.set('feature:job_queueing:disabled', nil)
      service.expects(:enqueue_all).once
      service.run
    end

    it 'enqueues if the feature :job_queueing is enabled explicitely' do
      Travis::Features.enable_for_all(:job_queueing)
      service.expects(:enqueue_all).once
      service.run
    end

    it 'does not enqueue if the feature :job_queueing is disabled explicitely' do
      Travis::Features.disable_for_all(:job_queueing)
      service.expects(:enqueue_all).never
      service.run
    end

    describe "with a timeout" do
      it "returns false when the timeout is hit" do
        Travis::Features.stubs(:feature_deactivated?).raises(Timeout::Error)
        service.disabled?.should == false
      end
    end
  end

  describe 'run' do
    let(:publisher) { stub(publish: true) }
    let(:test)      { stub_test(state: :created, enqueue: nil) }

    before :each do
      settings = OpenStruct.new(
        restricts_number_of_builds?: false,
        env_vars: []
      )
      test.repository.stubs(:settings).returns(settings)
      scope = stub('scope')
      scope.stubs(:all).returns([test])
      Job.stubs(:queueable).returns(scope)
      service.stubs(:publisher).returns(publisher)
    end

    it 'enqueues queueable jobs' do
      test.expects(:enqueue)
      service.run
    end

    it 'publishes queueable jobs' do
      payload = Travis::Api.data(test, for: 'worker', type: 'Job::Test', version: 'v0')
      publisher.expects(:publish).with(payload, properties: { type: 'test', persistent: true })
      service.run
    end

    it 'keeps a report of enqueued jobs' do
      service.run
      service.reports.should == { 'svenfuchs' => { total: 1, running: 0, max: 5, queueable: 1 } }
    end
  end

  describe 'Instrument' do
    let(:publisher) { Travis::Notification::Publisher::Memory.new }
    let(:event)     { publisher.events.last }
    let(:reports)   { { 'svenfuchs' => { total: 1, running: 0, max: 5, queueable: 1 } } }

    before :each do
      Travis::Notification.publishers.replace([publisher])
      service.stubs(:enqueue_all)
      service.stubs(:reports).returns(reports)
      service.run
    end

    it 'publishes a event' do
      event.should publish_instrumentation_event(
        event: 'travis.enqueue.services.enqueue_jobs.run:completed',
        message: "Travis::Enqueue::Services::EnqueueJobs#run:completed enqueued:\n  svenfuchs: total: 1, running: 0, max: 5, queueable: 1",
        data: {
          reports: reports
        }
      )
    end
  end
end
