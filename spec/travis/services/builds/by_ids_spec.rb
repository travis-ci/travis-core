require 'spec_helper'

describe Travis::Services::Builds::ByIds do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let!(:build)  { Factory(:build, :repository => repo, :state => :finished, :number => 1) }
  let(:service) { Travis::Services::Branches::ByIds.new(stub('user'), params) }

  attr_reader :params

  describe 'run' do
    it 'finds builds by a given list of ids' do
      @params = { :ids => [build.id] }
      service.run.should == [build]
    end
  end
end
