require 'spec_helper'

describe Travis::Services::Artifacts::One do
  include Support::ActiveRecord

  let(:log) { Factory(:log) }
  let(:service) { Travis::Services::Artifacts::One.new(stub('user'), params) }

  attr_reader :params

  describe 'one' do
    it 'finds the artifact with the given id' do
      @params = { :id => log.id }
      service.run.should == log
    end

    it 'raises if the artifact could not be found' do
      @params = { :id => log.id + 1 }
      lambda { service.run }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
