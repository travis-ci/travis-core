require 'spec_helper'

describe Travis::Services::Hooks do
  include Support::ActiveRecord

  let(:user)    { Factory(:user) }
  let(:repo)    { Factory(:repository) }
  let(:service) { Travis::Services::Hooks.new(user) }

  describe 'find_all' do
    it 'finds repositories where the current user has admin access' do
      user.permissions.create!(:repository => repo, :admin => true)
      service.find_all.map(&:repository).should include(repo)
    end

    it 'does not find repositories where the current user does not have admin access' do
      service.find_all.map(&:repository).should_not include(repo)
    end
  end

  describe 'find_one' do
    it 'finds a hook by id where the current user has admin access' do
      user.permissions.create!(:repository => repo, :admin => true)
      service.find_one(:id => repo.id).repository.should == repo
    end

    it 'finds a hook by slug where the current user has admin access' do
      user.permissions.create!(:repository => repo, :admin => true)
      service.find_one(:slug => repo.slug).repository.should == repo
    end

    it 'finds a hook by owner_name and name where the current user has admin access' do
      user.permissions.create!(:repository => repo, :admin => true)
      service.find_one(:owner_name => repo.owner_name, :name => repo.name).repository.should == repo
    end

    it 'raises if the record could not be found' do
      lambda { service.find_one(:id => repo.id + 1) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

