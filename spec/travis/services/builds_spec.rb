require 'spec_helper'

describe Travis::Services::Builds do
  let(:repository)    { stub('repository', :builds => builds) }
  let(:builds)        { stub('builds', :by_event_type => by_event_type, :includes => includes) }
  let(:by_event_type) { stub('by_event_type') }
  let(:includes)      { stub('includes', :find => result) }
  let(:result)        { stub('result') }
  let(:service)       { Travis::Services::Builds.new }

  before :each do
    Repository.stubs(:find).returns(repository)
  end

  describe 'find_all' do
    it 'finds recent builds when empty params given' do
      by_event_type.expects(:recent).returns(result)
      service.find_all({}).should == result
    end

    it 'finds builds older than the given number' do
      by_event_type.expects(:older_than).with(1).returns(result)
      service.find_all({ :after_number => 1}).should == result
    end
  end

  describe 'find_one' do
    before :each do
      Build.stubs(:includes).returns(includes)
    end

    it 'scopes the query to a repository_id if given' do
      Repository.expects(:find).with(1).returns(repository)
      service.find_one(:repository_id => 1, :id => 1).should == result
    end

    it 'includes associations' do
      Build.expects(:includes).returns(includes)
      service.find_one(:id => 1).should == result
    end

    it 'finds the build with the given id' do
      includes.expects(:find).with(1).returns(result)
      service.find_one(:id => 1).should == result
    end
  end
end

