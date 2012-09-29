require 'spec_helper'

describe Travis::Services::Accounts::All do
  include Support::ActiveRecord

  let!(:sven)    { Factory(:user, :login => 'sven') }
  let!(:travis)  { Factory(:org, :login => 'travis-ci') }
  let!(:sinatra) { Factory(:org, :login => 'sinatra') }

  let!(:repos) do
    Factory(:repository, :owner => sven, :owner_name => 'sven', :name => 'minimal')
    Factory(:repository, :owner => travis, :owner_name => 'travis-ci', :name => 'travis-ci')
    Factory(:repository, :owner => travis, :owner_name => 'travis-ci', :name => 'travis-core')
    Factory(:repository, :owner => sinatra, :owner_name => 'sinatra', :name => 'sinatra')
  end

  let(:service) { Travis::Services::Accounts::All.new(sven, {}) }

  before :each do
    Repository.all.each do |repo|
      sven.permissions.create!(:repository => repo, :admin => true) unless repo.name == 'sinatra'
    end
    sven.organizations << travis
  end

  describe 'run' do
    it 'includes the user' do
      service.run.should include(Account.from(sven))
    end

    it 'includes accounts where the user has admin access' do
      service.run.should include(Account.from(travis))
    end

    it 'does not include accounts where the user does not have admin access' do
      service.run.should_not include(Account.from(sinatra))
    end

    it 'includes repository counts' do
      service.run.map(&:repos_count).should == [1, 2]
    end
  end
end

