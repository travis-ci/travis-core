require 'spec_helper'

describe Travis::Services::Hooks::FindAll do
  include Support::ActiveRecord

  let(:user)    { User.first || Factory(:user) }
  let(:repo)    { Factory(:repository) }
  let(:service) { Travis::Services::Hooks::FindAll.new(user, params) }

  before :each do
    user.permissions.create!(:repository => repo, :admin => true)
  end

  attr_reader :params

  it 'finds repositories where the current user has admin access' do
    @params = {}
    service.run.should include(repo)
  end

  it 'does not find repositories where the current user does not have admin access' do
    @params = {}
    user.permissions.delete_all
    service.run.should_not include(repo)
  end

  it 'finds repositories by a given owner_name where the current user has admin access' do
    @params = { :owner_name => repo.owner_name }
    service.run.should include(repo)
  end

  it 'does not find repositories by a given owner_name where the current user does not have admin access' do
    @params = { :owner_name => 'rails' }
    service.run.should_not include(repo)
  end
end
