require 'spec_helper'

describe Travis::Services::Jobs do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository) }
  let!(:job)    { Factory(:test, :repository => repo, :state => :created, :queue => 'builds.common') }
  let(:service) { Travis::Services::Jobs.new }

  describe 'find_all' do
    it 'finds queued jobs' do
      service.find_all.should include(job)
    end

    describe 'given a queue name' do
      it 'finds jobs on the given queue' do
        service.find_all({ :queue => 'builds.common'}).should include(job)
      end

      it 'does not find jobs on other queues' do
        service.find_all({ :queue => 'builds.nodejs'}).should_not include(job)
      end
    end

    # TODO for all services test that the expected number of queries is issued
    # it 'includes associations' do
    #   where.expects(:includes).with(:commit).returns(result)
    #   service.find_all({ :queue => 'builds.common'}).should == result
    # end
  end

  describe 'find_one' do
    it 'finds the job with the given id' do
      service.find_one(:id => job.id).should == job
    end
  end
end
