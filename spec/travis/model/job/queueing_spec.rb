require 'spec_helper'

describe Job::Queueing do
  include Travis::Testing::Stubs

  let(:queueing) { Job::Queueing.new(test) }
  let(:queue)    { stub('queue', :publish => true) }

  before :each do
    Travis::Amqp::Publisher.stubs(:builds).returns(queue)
    Travis::Api.stubs(:data).returns({})
    test.stubs(:enqueue)
  end

  describe 'if the job is enqueueable' do
    before :each do
      Job::Limit.stubs(:enqueueable?).with(test).returns(true)
    end

    it 'enqueues the job' do
      test.expects(:enqueue)
      queueing.run
    end

    it 'publishes an amqp message' do
      queue.expects(:publish)
      queueing.run
    end

    it 'publishes on the job queue' do
      Travis::Amqp::Publisher.expects(:builds).with('builds.common').returns(queue)
      queueing.run
    end

    it 'publishes a worker payload' do
      Travis::Api.expects(:data).with(test, :for => 'worker', :type => 'Job::Test', :version => 'v0')
      queueing.run
    end
  end

  describe 'if the job is not enqueueable' do
    before :each do
      Job::Limit.stubs(:enqueueable?).with(test).returns(false)
    end

    it 'does not enqueue the job' do
      test.expects(:enqueue).never
      queueing.run
    end

    it 'does not publish an amqp message' do
      queue.expects(:publish).never
      queueing.run
    end
  end
end

RSpec::Matchers.define :be_queued_to do |publisher|
  match do |jobs|
    expected = jobs.map(&:id)
    actual = publisher.messages.map { |message| message.first['job']['id'] }
    actual.should == expected
    # jobs.map(&:state).uniq.should == ['queued']
  end

  failure_message_for_should do |jobs|
    actual = publisher.messages.map { |message| message.first['job']['id'] }
    "expected jobs #{jobs.map(&:id)} to be enqueued. instead we have:\n" +
    "  jobs #{actual} in publish messages\n"
  end
end

describe Job::Queueing::All do
  include Travis::Testing::Stubs
  include Support::ActiveRecord

  before :each do
    Travis::Features.start
  end

  it 'tries to enqueue each queueable job' do
    Job.stubs(:queueable).returns [test, test]
    Job::Queueing.any_instance.expects(:run).twice
    Job::Queueing::All.new.run
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
