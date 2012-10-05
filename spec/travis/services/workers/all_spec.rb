require 'spec_helper'

describe Travis::Services::Workers::All do
  include Support::ActiveRecord

  let(:worker)  { Factory(:worker) }
  let(:service) { Travis::Services::Workers::All.new(stub('user'), params) }

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
