require 'spec_helper'

describe Travis::Services::Hooks::All do
  include Support::ActiveRecord

  let(:user)    { User.first || Factory(:user) }
  let(:repo)    { Factory(:repository) }
  let(:service) { Travis::Services::Hooks::All.new(user, params) }

  before :each do
    user.permissions.create!(:repository => repo, :admin => true)
  end

  attr_reader :params

  it 'finds repositories where the current user has admin access' do
    @params = {}
    service.run.map(&:repository).should include(repo)
  end

  it 'does not find repositories where the current user does not have admin access' do
    @params = {}
    user.permissions.delete_all
    service.run.map(&:repository).should_not include(repo)
  end

  it 'finds repositories by a given owner_name where the current user has admin access' do
    @params = { :owner_name => repo.owner_name }
    service.run.map(&:repository).should include(repo)
  end

  it 'does not find repositories where the current user does not have admin access' do
    @params = { :owner_name => 'rails' }
    service.run.map(&:repository).should_not include(repo)
  end
end
