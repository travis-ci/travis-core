require 'spec_helper'

describe Travis::Services::Repositories do
  include Support::ActiveRecord

  let!(:repo)   { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let(:service) { Travis::Services::Repositories.new }

  describe 'find_all' do
    it 'finds repositories by a given list of ids' do
      service.find_all(:ids => [repo.id]).should == [repo]
    end

    it 'returns the recent timeline when given empty params' do
      service.find_all({}).should include(repo)
    end

    describe 'given a member name' do
      it 'finds a repository where that member has permissions' do
        repo.users << Factory(:user, :login => 'joshk')
        service.find_all(:member => 'joshk').should include(repo)
      end

      it 'does not find a repository where the member does not have permissions' do
        service.find_all(:member => 'joshk').should_not include(repo)
      end
    end

    describe 'given an owner_name name' do
      it 'finds a repository with that owner_name' do
        service.find_all(:owner_name => 'travis-ci').should include(repo)
      end

      it 'does not find a repository with another owner name' do
        service.find_all(:owner_name => 'sinatra').should_not include(repo)
      end
    end

    describe 'given a slug name' do
      it 'finds a repository with that slug' do
        service.find_all(:slug => 'travis-ci/travis-core').should include(repo)
      end

      it 'does not find a repository with a different slug' do
        service.find_all(:slug => 'travis-ci/travis-hub').should_not include(repo)
      end
    end

    describe 'given a search phrase' do
      it 'finds a repository matching that phrase' do
        service.find_all(:search => 'travis').should include(repo)
      end

      it 'does not find a repository that does not match that phrase' do
        service.find_all(:search => 'sinatra').should_not include(repo)
      end
    end
  end

  describe 'find_one' do
    it 'finds a repository by the given id' do
      service.find_one(:id => repo.id).should == repo
    end

    it 'finds a repository by the given owner_name and name' do
      service.find_one(:owner_name => repo.owner_name, :name => repo.name).should == repo
    end

    it 'raises if the repository could not be found' do
      lambda { service.find_one(:id => repo.id + 1) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'find_or_create_by' do
    it 'finds a repository by the given params if present' do
      params = { :owner_name => 'travis-ci', :name => 'travis-core' }
      lambda { service.find_or_create_by(params) }.should_not change(Repository, :count)
    end

    it 'creates a repository with the given params if not found' do
      params = { :owner_name => 'travis-ci', :name => 'travis-hub' }
      lambda { service.find_or_create_by(params) }.should change(Repository, :count).by(1)
    end
  end
end
