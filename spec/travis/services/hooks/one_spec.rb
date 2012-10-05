require 'spec_helper'

describe Travis::Services::Hooks::One do
  include Support::ActiveRecord

  let(:user)    { User.first || Factory(:user) }
  let(:repo)    { Factory(:repository) }
  let(:service) { Travis::Services::Hooks::One.new(user, params) }

  before :each do
    user.permissions.create!(:repository => repo, :admin => true)
  end

  attr_reader :params

  it 'finds a hook by id where the current user has admin access' do
    @params = { :id => repo.id }
    service.run.repository.should == repo
  end

  it 'finds a hook by slug where the current user has admin access' do
    @params = { :slug => repo.slug }
    service.run.repository.should == repo
  end

  it 'finds a hook by owner_name and name where the current user has admin access' do
    @params = { :owner_name => repo.owner_name, :name => repo.name }
    service.run.repository.should == repo
  end

  it 'does not raise if the repository could not be found' do
    @params = { :id => repo.id + 1 }
    lambda { service.run }.should_not raise_error
  end
end
