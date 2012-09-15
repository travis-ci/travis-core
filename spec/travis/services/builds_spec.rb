require 'spec_helper'

describe Travis::Services::Builds do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let!(:build)  { Factory(:build, :repository => repo, :state => :finished, :number => 1) }
  let(:service) { Travis::Services::Builds.new }

  describe 'find_all' do
    it 'finds builds by a given list of ids' do
      service.find_all(:ids => [build.id]).should == [build]
    end

    it 'finds recent builds when empty params given' do
      service.find_all(:repository_id => repo.id).should == [build]
    end

    it 'finds builds older than the given number' do
      service.find_all(:repository_id => repo.id, :after_number => 2).should == [build]
    end

    it 'scopes to the given repository_id' do
      Factory(:build, :repository => Factory(:repository), :state => :finished)
      service.find_all(:repository_id => repo.id).should == [build]
    end

    it 'returns an empty build scope when the repository could not be found' do
      service.find_all(:repository_id => repo.id + 1).should == Build.none
    end
  end

  describe 'find_one' do
    it 'finds a build by the given id' do
      service.find_one(:id => build.id).should == build
    end

    it 'scopes the query to a repository_id if given' do
      lambda { service.find_one(:repository_id => repo.id + 1, :id => build.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises if the repository could not be found' do
      lambda { service.find_one(:repository_id => repo.id + 1, :id => build.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises if the build could not be found' do
      lambda { service.find_one(:id => build.id + 1) }.should raise_error(ActiveRecord::RecordNotFound)
    end

    # TODO for all services test that the expected number of queries is issued
    # it 'includes associations' do
    #   Build.expects(:includes).returns(includes)
    #   service.find_one(:id => 1).should == result
    # end
  end
end

