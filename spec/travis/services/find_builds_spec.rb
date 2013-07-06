require 'spec_helper'

describe Travis::Services::FindBuilds do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let!(:build)  { Factory(:build, :repository => repo, :state => :finished, :number => 1) }
  let(:service) { described_class.new(stub('user'), params) }

  attr_reader :params

  describe 'run' do
    it 'finds recent builds when empty params given' do
      @params = { :repository_id => repo.id }
      service.run.should == [build]
    end

    it 'finds recent builds when no repo given' do
      @params = nil
      service.run.should == [build]
    end

    it 'finds builds older than the given number' do
      @params = { :repository_id => repo.id, :after_number => 2 }
      service.run.should == [build]
    end

    it 'finds builds with a given number, scoped by repository' do
      @params = { :repository_id => repo.id, :number => 1 }
      Factory(:build, :repository => Factory(:repository), :state => :finished, :number => 1)
      Factory(:build, :repository => repo, :state => :finished, :number => 2)
      service.run.should == [build]
    end

    it 'does not find by number if repository_id is missing' do
      @params = { :number => 1 }
      service.run.should == Build.none
    end

    it 'scopes to the given repository_id' do
      @params = { :repository_id => repo.id }
      Factory(:build, :repository => Factory(:repository), :state => :finished)
      service.run.should == [build]
    end

    it 'returns an empty build scope when the repository could not be found' do
      @params = { :repository_id => repo.id + 1 }
      service.run.should == Build.none
    end

    it 'finds builds by a given list of ids' do
      @params = { :ids => [build.id] }
      service.run.should == [build]
    end

    describe 'with pull requests' do
      it 'finds pull requests for event_type=pull_request' do
        request = Factory(:request, :event_type => 'pull_request')
        pull_request = Factory(:build, :repository => repo, :state => :finished, :number => 2, :request => request)
        @params = { :event_type => 'pull_request', :repository_id => repo.id }
        service.run.should == [pull_request]
      end
    end
  end

  describe 'updated_at' do
    it 'returns the latest updated_at time' do
      @params = { :repository_id => repo.id }
      Build.delete_all
      Factory(:build, :repository => repo, :state => :finished, :number => 1, :updated_at => Time.now - 1.hour)
      Factory(:build, :repository => repo, :state => :finished, :number => 1, :updated_at => Time.now)
      service.updated_at.to_s.should == Time.now.to_s
    end
  end
end
