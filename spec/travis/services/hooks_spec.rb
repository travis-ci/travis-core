require 'spec_helper'

describe Travis::Services::Hooks do
  include Support::ActiveRecord

  let(:user)    { User.first || Factory(:user) }
  let(:repo)    { Factory(:repository) }
  let(:service) { Travis::Services::Hooks.new(user) }

  before :each do
    user.permissions.create!(:repository => repo, :admin => true)
  end

  describe 'find_all' do
    it 'finds repositories where the current user has admin access' do
      service.find_all.map(&:repository).should include(repo)
    end

    it 'does not find repositories where the current user does not have admin access' do
      user.permissions.delete_all
      service.find_all.map(&:repository).should_not include(repo)
    end

    it 'finds repositories by a given owner_name where the current user has admin access' do
      service.find_all(:owner_name => repo.owner_name).map(&:repository).should include(repo)
    end

    it 'does not find repositories where the current user does not have admin access' do
      service.find_all(:owner_name => 'rails').map(&:repository).should_not include(repo)
    end
  end

  describe 'find_one' do
    it 'finds a hook by id where the current user has admin access' do
      service.find_one(:id => repo.id).repository.should == repo
    end

    it 'finds a hook by slug where the current user has admin access' do
      service.find_one(:slug => repo.slug).repository.should == repo
    end

    it 'finds a hook by owner_name and name where the current user has admin access' do
      service.find_one(:owner_name => repo.owner_name, :name => repo.name).repository.should == repo
    end

    it 'raises if the repository could not be found' do
      lambda { service.find_one(:id => repo.id + 1) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'update' do
    let(:params) { { :id => repo.id, :active => 'true' } }

    before :each do
      ServiceHook.any_instance.stubs(:set)
    end

    it 'sets the given :active param to the hook' do
      ServiceHook.any_instance.expects(:set).with(true, user)
      service.update(params)
    end

    it 'returns the repository' do
      service.update(params).should == repo
    end
  end
end

