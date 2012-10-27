require 'spec_helper'

describe Travis::Services::Jobs::Enqueue do
  include Travis::Testing::Stubs
  include Support::ActiveRecord

  let(:subject) { Travis::Services::Jobs::Enqueue }
  let(:service) { subject.new }

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
  end

  describe 'run' do
    let(:publisher) { stub(publish: true) }
    let(:test)      { stub_test(state: :created, enqueue: nil) }

    before :each do
      Job.stubs(:queueable).returns([test])
      service.stubs(:publisher).returns(publisher)
    end

    it 'enqueues queueable jobs' do
      test.expects(:enqueue)
      service.run
    end

    it 'publishes queueable jobs' do
      payload = Travis::Api.data(test, for: 'worker', type: 'Job::Test', version: 'v0')
      publisher.expects(:publish).with(payload, properties: { type: 'test' })
      service.run
    end
  end
end
