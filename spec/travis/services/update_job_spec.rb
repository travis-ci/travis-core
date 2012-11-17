require 'spec_helper'

describe Travis::Services::UpdateJob do
  include Travis::Testing::Stubs

  let(:service) { described_class.new('data' => { 'id' => 1, 'result' => 0 }) }

  before :each do
    Job::Test.stubs(:find).returns(test)
    test.stubs(:update_attributes)
  end

  it 'finds the job' do
    Job::Test.expects(:find).with(1).returns(test)
    service.run
  end

  it 'updates the job attributes' do
    test.expects(:update_attributes).with(result: 0)
    service.run
  end
end


