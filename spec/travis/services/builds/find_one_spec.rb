require 'spec_helper'

describe Travis::Services::Builds::FindOne do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let!(:build)  { Factory(:build, :repository => repo, :state => :finished, :number => 1) }
  let(:params)  { { :id => build.id } }
  let(:service) { Travis::Services::Builds::FindOne.new(stub('user'), params) }

  describe 'run' do
    it 'finds a build by the given id' do
      service.run.should == build
    end

    it 'does not raise if the build could not be found' do
      @params = { :id => build.id + 1 }
      lambda { service.run }.should_not raise_error
    end
  end

  describe 'updated_at' do
    it 'returns builds updated_at attribute' do
      service.updated_at.to_s.should == build.updated_at.to_s
    end
  end

  describe 'with newer associated record' do
    it 'returns updated_at of newest result' do
      build.update_attribute(:updated_at, 5.minutes.ago)
      build.reload.updated_at.should < build.matrix.first.updated_at
      service.updated_at.to_s.should == build.matrix.first.updated_at.to_s
    end
  end

  describe 'final?' do
    it 'returns true if the build is finished' do
      build.update_attributes!(:state => :finished)
      service.final?.should be_true
    end

    it 'returns false if the build is not finished' do
      build.update_attributes!(:state => :started)
      service.final?.should be_false
    end
  end
end
