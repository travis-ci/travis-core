require 'spec_helper'

describe Travis::Services::Artifacts do
  include Support::ActiveRecord

  let(:log)     { Factory(:log) }
  let(:service) { Travis::Services::Artifacts.new }

  describe 'find_one' do
    it 'finds the artifact with the given id' do
      service.find_one(:id => log.id).should == log
    end

    it 'raises if the artifact could not be found' do
      lambda { service.find_one(:id => log.id + 1) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
