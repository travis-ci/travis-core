require 'spec_helper'

describe Travis::Services::Workers::FindOne do
  include Support::ActiveRecord

  let(:worker)  { Factory(:worker) }
  let(:service) { Travis::Services::Workers::FindOne.new(stub('user'), params) }

  attr_reader :params

  it 'finds a worker by its id' do
    @params = { :id => worker.id }
    service.run.should == worker
  end

  it 'does not raise if the worker could not be found' do
    @params = { :id => worker.id + 1 }
    lambda { service.run }.should_not raise_error
  end
end
