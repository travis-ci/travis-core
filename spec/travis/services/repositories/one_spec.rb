require 'spec_helper'

describe Travis::Services::Repositories::One do
  include Support::ActiveRecord

  let!(:repo)   { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let(:service) { Travis::Services::Repositories::One.new(stub('user'), params) }

  attr_reader :params

  it 'finds a repository by the given id' do
    @params = { :id => repo.id }
    service.run.should == repo
  end

  it 'finds a repository by the given owner_name and name' do
    @params = { :owner_name => repo.owner_name, :name => repo.name }
    service.run.should == repo
  end

  it 'does not raise if the repository could not be found' do
    @params = { :id => repo.id + 1 }
    lambda { service.run }.should_not raise_error
  end
end
