require 'spec_helper'

describe Travis::Services::Artifacts::One do
  include Support::ActiveRecord

  let(:log) { Factory(:log) }
  let(:service) { Travis::Services::Artifacts::One.new(stub('user'), params) }

  attr_reader :params

  it 'finds the artifact with the given id' do
    @params = { :id => log.id }
    service.run.should == log
  end

  it 'does not raise if the artifact could not be found' do
    @params = { :id => log.id + 1 }
    lambda { service.run }.should_not raise_error
  end
end
