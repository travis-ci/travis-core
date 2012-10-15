require 'spec_helper'

describe Travis::Services::Events::FindAll do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let(:build)   { Factory(:build, :repository => repo, :state => :finished, :number => 1) }
  let!(:event)  { Factory(:event, :event => 'build:finished', :repository => repo, :source => build) }
  let(:service) { Travis::Services::Events::FindAll.new(stub('user'), params) }

  attr_reader :params

  describe 'run' do
    it 'finds events belonging to the given repository id' do
      @params = { :repository_id => repo.id }
      service.run.should == [event]
    end
  end

  describe 'updated_at' do
    it 'returns the latest updated_at time' do
      @params = { :repository_id => repo.id }
      Event.delete_all
      Factory(:event, :repository => repo, :updated_at => Time.now - 1.hour)
      Factory(:event, :repository => repo, :updated_at => Time.now)
      service.updated_at.should == Time.now
    end
  end
end

