require 'spec_helper'

describe Travis::Services::Jobs::Enqueue::Limit do
  include Travis::Testing::Stubs
  include Support::ActiveRecord

  let(:subject) { Travis::Services::Jobs::Enqueue::Limit }
  let(:jobs)    { 10.times.map { stub_test } }
  let(:limit)   { subject.new(org, jobs) }

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

  it 'allows all jobs for orgs that have a custom queue' do
    org.stubs(login: 'rails')
    limit.stubs(running: 10)
    limit.queueable.should == jobs
  end

  it 'gives a readable report' do
    limit.stubs(running: 3)
    limit.report.should == { total: 10, running: 3, max: 5, queueable: 2 }
  end
end
