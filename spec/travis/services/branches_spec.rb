require 'spec_helper'

describe Travis::Services::Branches do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let!(:build)  { Factory(:build, :repository => repo, :state => :finished) }
  let(:service) { Travis::Services::Branches.new }

  describe 'find_all' do
    it 'finds the last builds of the given repository grouped per branch' do
      service.find_all(:repository_id => repo.id).should include(build)
    end

    it 'scopes to the given repository' do
      build = Factory(:build, :repository => Factory(:repository), :state => :finished)
      service.find_all(:repository_id => repo.id).should_not include(build)
    end

    it 'returns an empty build scope when the repository could not be found' do
      service.find_all(:repository_id => repo.id + 1).should == Build.none
    end
  end
end
