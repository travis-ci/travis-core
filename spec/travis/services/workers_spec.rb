require 'spec_helper'

describe Travis::Services::Workers do
  include Support::ActiveRecord

  let(:worker)  { Factory(:worker) }
  let(:service) { Travis::Services::Workers.new }

  describe 'find_all' do
    it 'finds workers' do
      service.find_all.should include(worker)
    end
  end

  describe 'find_one' do
    it 'finds a worker by its id' do
      service.find_one(:id => worker.id).should == worker
    end

    it 'raises if the worker could not be found' do
      lambda { service.find_one(:id => worker.id + 1) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
