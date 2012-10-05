require 'spec_helper'

describe Travis::Services::Jobs::All do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository) }
  let!(:job)    { Factory(:test, :repository => repo, :state => :created, :queue => 'builds.common') }
  let(:service) { Travis::Services::Jobs::All.new(stub('user'), params) }

  attr_reader :params

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

  # TODO for all services test that the expected number of queries is issued
  # it 'includes associations' do
  #   @params = { :queue => 'builds.common'}
  #   where.expects(:includes).with(:commit).returns(result)
  #   service.run.should == result
  # end
end
