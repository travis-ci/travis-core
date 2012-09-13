require 'spec_helper'

describe Travis::Services::Repositories do
  let(:timeline) { stub('timeline', :recent => recent) }
  let(:recent)   { stub('recent') }
  let(:result)   { stub('result') }
  let(:service)  { Travis::Services::Repositories.new }

  before :each do
    Repository.stubs(:timeline).returns(timeline)
  end

  describe 'find_all' do
    it 'returns the recent timeline when given empty params' do
      service.find_all({}).should == recent
    end

    it 'scopes by member when given a :member param' do
      recent.expects(:by_member).with('joshk').returns(result)
      service.find_all(:member => 'joshk').should == result
    end

    it 'scopes by owner_name when given an :owner_name param' do
      recent.expects(:by_owner_name).with('joshk').returns(result)
      service.find_all(:owner_name => 'joshk').should == result
    end

    it 'scopes by owner_name when given a :login param' do
      recent.expects(:by_owner_name).with('joshk').returns(result)
      service.find_all(:login => 'joshk').should == result
    end

    it 'scopes by slug when given a :slug param' do
      recent.expects(:by_slug).with('travis-ci/travis-core').returns(result)
      service.find_all(:slug => 'travis-ci/travis-core').should == result
    end

    it 'scopes to search when given a :search param' do
      recent.expects(:search).with('something').returns(result)
      service.find_all(:search => 'something').should == result
    end
  end

  describe 'find_one' do
    it 'finds a repository by the given params' do
      Repository.expects(:find_by).with(:id => 1).returns(result)
      service.find_one(:id => 1).should == result
    end
  end

  describe 'find_or_create_by' do
    it 'finds a repository by the given params if present' do
      params = { :owner_name => 'travis-ci', :name => 'travis-core' }
      Repository.expects(:find_by).with(params).returns(result)
      service.find_or_create_by(params).should == result
    end

    it 'creates a repository with the given params if not found' do
      params = { :owner_name => 'travis-ci', :name => 'travis-core' }
      Repository.expects(:find_by).with(params).returns(nil)
      Repository.expects(:create!).with(params).returns(result)
      service.find_or_create_by(params).should == result
    end
  end
end


