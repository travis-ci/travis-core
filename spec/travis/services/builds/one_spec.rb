require 'spec_helper'

describe Travis::Services::Builds::One do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let!(:build)  { Factory(:build, :repository => repo, :state => :finished, :number => 1) }
  let(:service) { Travis::Services::Builds::One.new(stub('user'), params) }

  attr_reader :params

  it 'finds a build by the given id' do
    @params = { :id => build.id }
    service.run.should == build
  end

  it 'does not raise if the build could not be found' do
    @params = { :id => build.id + 1 }
    lambda { service.run }.should_not raise_error
  end

  # TODO for all services test that the expected number of queries is issued
  # it 'includes associations' do
  #   @params = { :id => build.id }
  #   Build.expects(:includes).returns(includes)
  #   service.run.should == result
  # end
end
