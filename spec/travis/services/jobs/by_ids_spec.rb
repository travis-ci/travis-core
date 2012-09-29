require 'spec_helper'

describe Travis::Services::Jobs::ByIds do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository) }
  let!(:job)    { Factory(:test, :repository => repo, :state => :created, :queue => 'builds.common') }
  let(:service) { Travis::Services::Jobs::ByIds.new(stub('user'), params) }

  attr_reader :params

  describe 'run' do
    it 'finds jobs by a given list of ids' do
      @params = { :ids => [job.id] }
      service.run.should == [job]
    end
  end
end
