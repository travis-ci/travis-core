require 'spec_helper'

describe Travis::Service::Jobs do
  let(:queued)   { stub('queued', :where => where) }
  let(:where)    { stub('where', :includes => result) }
  let(:result)   { stub('result') }
  let(:service)  { Travis::Service::Jobs.new }

  describe 'find_all' do
    before :each do
      Job.stubs(:queued).returns(queued)
    end

    it 'finds queued jobs' do
      Job.expects(:queued).returns(queued)
      service.find_all({ :queue => 'builds.common'}).should == result
    end

    it 'finds jobs on the given queue' do
      queued.expects(:where).with(:queue => 'builds.common').returns(where)
      service.find_all({ :queue => 'builds.common'}).should == result
    end

    it 'includes associations' do
      where.expects(:includes).with(:commit).returns(result)
      service.find_all({ :queue => 'builds.common'}).should == result
    end
  end

  describe 'find_one' do
    it 'finds the job with the given id' do
      Job.expects(:find).with(1).returns(result)
      service.find_one(:id => 1).should == result
    end
  end
end
