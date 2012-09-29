require 'spec_helper'

describe Travis::Services::Builds::One do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let!(:build)  { Factory(:build, :repository => repo, :state => :finished, :number => 1) }
  let(:service) { Travis::Services::Builds::One.new(stub('user'), params) }

  attr_reader :params

  describe 'run' do
    it 'finds a build by the given id' do
      @params = { :id => build.id }
      service.run.should == build
    end

    it 'scopes the query to a repository_id if given' do
      @params = { :repository_id => repo.id, :id => build.id }
      service.run.should == build
    end

    it 'raises if the repository could not be found' do
      @params = { :repository_id => repo.id + 1, :id => build.id }
      lambda { service.run }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises if the build could not be found' do
      @params = { :id => build.id + 1 }
      lambda { service.run }.should raise_error(ActiveRecord::RecordNotFound)
    end

    # TODO for all services test that the expected number of queries is issued
    # it 'includes associations' do
    #   @params = { :id => build.id }
    #   Build.expects(:includes).returns(includes)
    #   service.run.should == result
    # end
  end
end

