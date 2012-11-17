require 'spec_helper'

describe Travis::Services::FindWorkers do
  include Support::ActiveRecord

  let(:worker)  { Factory(:worker) }
  let(:service) { described_class.new(stub('user'), params) }

  attr_reader :params

  it 'finds workers' do
    @params = {}
    service.run.should include(worker)
  end

  it 'finds workers by a given list of ids' do
    @params = { :ids => [worker.id] }
    service.run.should == [worker]
  end
end
