require 'spec_helper'

describe Travis::Services::Jobs::FindOne do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository) }
  let!(:job)    { Factory(:test, :repository => repo, :state => :created, :queue => 'builds.common') }
  let(:params)  { { :id => job.id } }
  let(:service) { Travis::Services::Jobs::FindOne.new(stub('user'), params) }

  describe 'run' do
    it 'finds the job with the given id' do
      @params = { :id => job.id }
      service.run.should == job
    end

    it 'does not raise if the job could not be found' do
      @params = { :id => job.id + 1 }
      lambda { service.run }.should_not raise_error
    end
  end

  describe 'updated_at' do
    it 'returns jobs updated_at attribute' do
      service.updated_at.should == job.updated_at
    end
  end

  describe 'final?' do
    it 'returns true if the job is finished' do
      job.update_attributes!(:state => :finished)
      service.final?.should be_true
    end

    it 'returns false if the job is not finished' do
      job.update_attributes!(:state => :started)
      service.final?.should be_false
    end
  end
end
