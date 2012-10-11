require 'spec_helper'

describe Travis::Services::Jobs::All do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository) }
  let!(:job)    { Factory(:test, :repository => repo, :state => :created, :queue => 'builds.common') }
  let(:service) { Travis::Services::Jobs::All.new(stub('user'), params) }

  attr_reader :params

  describe 'run' do
    it 'finds jobs on the given queue' do
      @params = { :queue => 'builds.common' }
      service.run.should include(job)
    end

    it 'does not find jobs on other queues' do
      @params = { :queue => 'builds.nodejs' }
      service.run.should_not include(job)
    end

    it 'finds jobs by a given list of ids' do
      @params = { :ids => [job.id] }
      service.run.should == [job]
    end
  end

  describe 'updated_at' do
    it 'returns the latest updated_at time' do
      @params = { :queue => 'builds.common' }
      Job.delete_all
      Factory(:test, :repository => repo, :state => :finished, :queue => 'build.common', :updated_at => Time.now - 1.hour)
      Factory(:test, :repository => repo, :state => :finished, :queue => 'build.common', :updated_at => Time.now)
      service.updated_at.should == Time.now
    end
  end
end
