require 'spec_helper'

describe Travis::Enqueue::Services::EnqueueJobs::Limit do
  include Travis::Testing::Stubs
  include Support::ActiveRecord

  let(:jobs)    { 10.times.map { stub_test } }
  let(:limit)   { described_class.new(org, jobs) }

  before do
    Travis.config.limit_per_repo_enabled = true
    jobs.each do |job|
      job.repository.stubs(:settings).returns OpenStruct.new({:restricts_number_of_builds? => false})
    end
  end

  it 'allows the first 5 jobs if none are running by default' do
    limit.stubs(running: 0)
    limit.queueable.should == jobs[0, 5]
  end

  it 'allows one job if 4 are running by default' do
    limit.stubs(running: 4)
    limit.queueable.should == jobs[0, 1]
  end

  it 'allows the first 8 jobs if the org is allowed 8 jobs' do
    Travis.config.queue.limit.stubs(by_owner: { org.login => 8 })
    limit.stubs(running: 0)
    limit.queueable.should == jobs[0, 8]
  end

  it 'allows all jobs if the limit is set to -1' do
    Travis.config.queue.limit.stubs(by_owner: { org.login => -1 })
    limit.stubs(running: 10)
    limit.queueable.should == jobs
  end

  it 'gives a readable report' do
    limit.stubs(running: 3)
    limit.report.should == { total: 10, running: 3, max: 5, queueable: 2 }
  end

  describe "limit per repository" do
    before do
      jobs.each do |job|
        job.repository.stubs(:settings).returns OpenStruct.new({:restricts_number_of_builds? => true, :maximum_number_of_builds => 3})
      end
    end

    it 'should only schedule the maximum number of builds for a single repository' do
      limit.stubs(running: 1)
      limit.stubs(running_jobs: [OpenStruct.new(repository_id: test.repository_id)])
      limit.queueable.size.should == 2
    end

    it "should schedule jobs for other repositories" do
      test = stub_test(repository_id: 11111, repository: stub_repo)
      test.repository.stubs(:settings).returns OpenStruct.new({:restricts_number_of_builds? => false})
      limit.stubs(running: 1)
      limit.stubs(running_jobs: [OpenStruct.new(repository_id: test.repository_id)])
      limit.queueable.size.should == 3
    end

    it "doesn't fail for repositories with no running jobs and restriction enabled" do
      test = stub_test(repository_id: 11111, repository: stub_repo)
      limit.stubs(running: 1)
      limit.stubs(running_jobs: [OpenStruct.new(repository_id: test.repository_id)])
      limit.queueable.size.should == 3
    end

    it "doesn't allow for a repository maximum higher than the total maximum" do
      jobs.each do |job|
        job.repository.stubs(:settings).returns OpenStruct.new({:restricts_number_of_builds? => true, :maximum_number_of_builds => 10})
        limit.queueable.size.should == 5
      end
    end

    it "doesn't add the filter with limit per repo disabled" do
      Travis.config.limit_per_repo_enabled = false
      limit.stubs(running: 0)
      limit.queueable.size.should == 5
    end
  end
end
