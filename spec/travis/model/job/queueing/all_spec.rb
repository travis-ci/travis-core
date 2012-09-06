require 'spec_helper'

describe Job::Queueing::All do
  include Travis::Testing::Stubs
  include Support::ActiveRecord

  before :each do
    Travis::Features.start
    Travis::Features.redis.set('feature:job_queueing:disabled', nil)
  end

  describe 'if the feature :job_queueing is not deactivated (default)' do
    before :each do
      Job.stubs(:queueable).returns [test, test]
    end

    it 'tries to enqueue each queueable job' do
      Job::Queueing.any_instance.expects(:run).twice
      Job::Queueing::All.new.run
    end
  end

  describe 'if the feature :job_queueing is deactivated explicitely' do
    before :each do
      Travis::Features.disable_for_all(:job_queueing)
      Job.stubs(:queueable).returns [test, test]
    end

    it 'does not try to enqueue any jobs' do
      Job::Queueing.any_instance.expects(:run).never
      Job::Queueing::All.new.run
    end
  end

  describe 'queueing order' do
    let(:config)    { { :rvm => ['1.9.3', 'rbx', 'jruby'] } }
    let(:publisher) { Support::Mocks::Amqp::Publisher.new }

    before :each do
      Travis::Amqp::Publisher.stubs(:builds).returns(publisher)
    end

    def create_builds(count)
      count.times { Factory(:build, :config => config) }
    end

    def finish(jobs, publisher)
      jobs.each do |job|
        job.finish!
        publisher.messages.delete_if do |message|
          message.first['job']['id'] == job.id
        end
      end
    end

    it 'enqueues jobs in the expected order' do
      # we initially have 9 jobs
      create_builds(3)
      Job::Queueing::All.new.run

      # now the first 5 of them should be queued
      jobs = Job.order(:id).all
      jobs[0, 5].should be_queued_to(publisher)
      jobs[5, 4].should_not be_queued_to(publisher)

      # create 3 more jobs and re-enqueue
      create_builds(1)
      Job::Queueing::All.new.run

      # now still the first 5 of them should be queued
      jobs = Job.order(:id).all
      jobs[0, 5].should be_queued_to(publisher)
      jobs[5, 7].should_not be_queued_to(publisher)

      # finish two jobs and re-enqueue
      finish(jobs[0, 2], publisher)
      Job::Queueing::All.new.run

      jobs = Job.order(:id).all
      jobs[0, 2].should_not be_queued_to(publisher)
      jobs[2, 5].should be_queued_to(publisher)
      jobs[7, 5].should_not be_queued_to(publisher)

      # finish 4 jobs and re-enqueue
      finish(jobs[2, 4], publisher)
      Job::Queueing::All.new.run

      jobs = Job.order(:id).all
      jobs[0, 6].should_not be_queued_to(publisher)
      jobs[6, 5].should be_queued_to(publisher)
      jobs[11, 1].should_not be_queued_to(publisher)
    end
  end
end

