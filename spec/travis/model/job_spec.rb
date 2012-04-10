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
      Travis::Notifications.expects(:dispatch).with('job:test:log', job, :_log => 'chars')
      Job::Test.append_log!(job.id, 'chars')
    end
  end

  describe 'before_create' do
    it 'instantiates the log artifact' do
      job = Job::Test.create!(:repository => Factory(:repository), :commit => Factory(:commit), :owner => Factory(:build))
      job.reload.log.should be_instance_of(Artifact::Log)
    end

    it 'sets the state attribute' do
      job = Job::Test.create!(:repository => Factory(:repository), :commit => Factory(:commit), :owner => Factory(:build))
      job.reload.should be_created
    end

    it 'sets the queue attribute' do
      job = Job::Test.create!(:repository => Factory(:repository), :commit => Factory(:commit), :owner => Factory(:build))
      job.reload.queue.should == 'builds.common'
    end
  end

  describe 'duration' do
    it 'returns nil if both started_at is not populated' do
      job = Job.new(:finished_at => Time.now)
      job.duration.should be_nil
    end

    it 'returns nil if both finished_at is not populated' do
      job = Job.new(:started_at => Time.now)
      job.duration.should be_nil
    end

    it 'returns the duration if both started_at and finished_at are populated' do
      job = Job.new(:started_at => 20.seconds.ago, :finished_at => 10.seconds.ago)
      job.duration.should == 10
    end
  end

  describe 'tagging' do
    let(:job) { Factory.create(:test) }

    before :each do
      Job::Tagging.stubs(:rules).returns [
        { 'tag' => 'rake_not_bundled',   'pattern' => 'rake is not part of the bundle.' }
      ]
    end

    it 'should tag a job its log contains a particular string' do
      job.start!
      job.reload.append_log!('rake is not part of the bundle')
      job.finish!

      job.reload.tags.should == "rake_not_bundled"
    end
  end
end
