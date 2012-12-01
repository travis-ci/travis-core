require 'spec_helper'

describe Travis::Services::FindArtifact do
  include Support::ActiveRecord

  let(:job)     { Factory(:test) }
  let(:log)     { Factory(:log, :job => job) }
  let(:params)  { { :id => log.id } }
  let(:service) { described_class.new(stub('user'), params) }

  describe 'run' do
    it 'finds the artifact with the given id' do
      service.run.should == log
    end

    it 'does not raise if the artifact could not be found' do
      @params = { :id => log.id + 1 }
      lambda { service.run }.should_not raise_error
    end
  end

  # TODO jobs can be requeued, so finished jobs are no more final
  #
  # describe 'final?' do
  #   it 'returns true if the job is finished' do
  #     log.job.update_attributes!(:state => :finished)
  #     service.final?.should be_true
  #   end

  #   it 'returns false if the job is not finished' do
  #     log.job.update_attributes!(:state => :started)
  #     service.final?.should be_false
  #   end
  # end
end
