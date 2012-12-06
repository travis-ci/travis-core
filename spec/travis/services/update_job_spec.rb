require 'spec_helper'

describe Travis::Services::UpdateJob do
  include Travis::Testing::Stubs

  let(:service) { described_class.new('data' => { 'id' => 1, 'result' => 0 }) }

  before :each do
    Job::Test.stubs(:find).returns(test)
    test.stubs(:update_attributes!)
  end

  it 'finds the job' do
    Job::Test.expects(:find).with(1).returns(test)
    service.run
  end

  it 'updates the job attributes' do
    test.expects(:update_attributes!).with(result: 0)
    service.run
  end
end

describe Travis::Services::UpdateJob do
  include Support::ActiveRecord

  let(:service) { described_class.new(data: payload) }

  describe 'job:finished' do
    let(:event)   { 'job:test:started' } # TODO should be passed by the handler
    let(:payload) { WORKER_PAYLOADS['job:test:finished'].merge('id' => job.id) }
    let(:build)   { Factory(:build, state: :started) }
    let(:job)     { Factory(:test, source: build, state: :started) }

    before :each do
      build.matrix.delete_all
      job.repository.update_attributes(last_build_state: :started)
    end

    it 'sets the job state to passed' do
      service.run
      job.reload.state.should == 'passed'
    end

    it 'sets the build state to passed' do
      service.run
      job.reload.source.state.should == 'passed'
    end

    it 'sets the repository last_build_state to passed' do
      service.run
      job.reload.repository.last_build_state.should == 'passed'
    end
  end
end
