require 'spec_helper'
require 'support/active_record'

describe Job do
  include Support::ActiveRecord

  describe ".queued" do
    let(:jobs) { [Factory.create(:test), Factory.create(:test), Factory.create(:test)] }

    it "returns jobs that are created but not started or finished" do
      jobs.first.start!
      jobs.third.start!
      jobs.third.finish!

      Job.queued.should include(jobs.second)
      Job.queued.should_not include(jobs.first)
      Job.queued.should_not include(jobs.third)
    end
  end

  describe :append_log! do
    let!(:job) { Factory(:test) }

    it "appends chars to the log artifact" do
      line = "$ bundle install --pa"
      Artifact::Log.expects(:append).with(job.id, line)
      job.append_log!(line)
    end

    it 'notifies observers' do
      Travis::Notifications.expects(:dispatch).with('job:test:log', job, :build => { :_log => 'chars' })
      Job::Test.append_log!(job.id, 'chars')
    end
  end
end
