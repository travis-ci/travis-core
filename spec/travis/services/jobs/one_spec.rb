require 'spec_helper'

describe Travis::Services::Jobs::One do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository) }
  let!(:job)    { Factory(:test, :repository => repo, :state => :created, :queue => 'builds.common') }
  let(:service) { Travis::Services::Jobs::One.new(stub('user'), params) }

  attr_reader :params

  describe 'run' do
    it 'finds the job with the given id' do
      @params = { :id => job.id }
      service.run.should == job
    end

    it 'raises if the job could not be found' do
      @params = { :id => job.id + 1 }
      lambda { service.run }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
