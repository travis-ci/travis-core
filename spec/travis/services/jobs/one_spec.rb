require 'spec_helper'

describe Travis::Services::Jobs::One do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository) }
  let!(:job)    { Factory(:test, :repository => repo, :state => :created, :queue => 'builds.common') }
  let(:service) { Travis::Services::Jobs::One.new(stub('user'), params) }

  attr_reader :params

  it 'finds the job with the given id' do
    @params = { :id => job.id }
    service.run.should == job
  end

  it 'does not raise if the job could not be found' do
    @params = { :id => job.id + 1 }
    lambda { service.run }.should_not raise_error
  end
end
