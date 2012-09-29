require 'spec_helper'

describe Travis::Services::Workers::One do
  include Support::ActiveRecord

  let(:worker)  { Factory(:worker) }
  let(:service) { Travis::Services::Workers::One.new(stub('user'), params) }

  attr_reader :params

  describe 'find_one' do
    it 'finds a worker by its id' do
      @params = { :id => worker.id }
      service.run.should == worker
    end

    it 'raises if the worker could not be found' do
      @params = { :id => worker.id + 1 }
      lambda { service.run }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
