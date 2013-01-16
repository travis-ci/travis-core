require 'spec_helper'

describe Travis::Services::FindWorkers do
  include Support::Redis

  let!(:workers) { [Worker.create(full_name: 'one'), Worker.create(full_name: 'two')] }
  let(:service)  { described_class.new(stub('user'), params) }

  attr_reader :params

  it 'finds workers' do
    @params = {}
    service.run.should == workers
  end

  it 'finds workers by a given list of ids' do
    @params = { ids: [workers.first.id] }
    workers
    service.run.should == [workers.first]
  end
end
