require 'spec_helper'

describe Travis::Services::Profile do
  include Support::ActiveRecord

  let!(:sven)    { Factory(:user, :login => 'sven') }
  let!(:travis)  { Factory(:org, :login => 'travis-ci') }
  let!(:sinatra) { Factory(:org, :login => 'sinatra') }

  let!(:repos) do
    Factory(:repository, :owner => sven, :owner_name => 'svenfuchs', :name => 'minimal')
    Factory(:repository, :owner => travis, :owner_name => 'travis-ci', :name => 'travis-ci')
    Factory(:repository, :owner => travis, :owner_name => 'travis-ci', :name => 'travis-core')
    Factory(:repository, :owner => sinatra, :owner_name => 'sinatra', :name => 'sinatra')
  end

  let(:service) { Travis::Services::Profile.new(sven) }

  before :each do
    Repository.all.each do |repo|
      sven.permissions.create!(:repository => repo, :admin => true) unless repo.name == 'sinatra'
    end
    sven.organizations << travis
  end

  describe 'find_one' do
    it 'includes the user' do
      service.find_one[:user].should == sven
    end

    it 'includes accounts where the user has admin access' do
      service.find_one[:accounts].should == [sven, travis]
    end

    it 'includes repository counts' do
      service.find_one[:repository_counts].should == { 'svenfuchs' => 1, 'travis-ci' => 2 }
    end
  end
end

