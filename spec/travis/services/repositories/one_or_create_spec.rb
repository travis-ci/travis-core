require 'spec_helper'

describe Travis::Services::Repositories::OneOrCreate do
  include Support::ActiveRecord

  let!(:repo)   { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let(:service) { Travis::Services::Repositories::OneOrCreate.new(stub('user'), params) }

  attr_reader :params

  describe 'run' do
    it 'finds a repository by the given params if present' do
      @params = { :owner_name => 'travis-ci', :name => 'travis-core' }
      lambda { service.run }.should_not change(Repository, :count)
    end

    it 'creates a repository with the given params if not found' do
      @params = { :owner_name => 'travis-ci', :name => 'travis-hub' }
      lambda { service.run }.should change(Repository, :count).by(1)
    end
  end
end
