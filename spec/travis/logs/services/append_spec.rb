require 'spec_helper'

describe Travis::Logs::Services::Append do
  include Travis::Testing::Stubs

  let(:service) { described_class.new('data' => { 'id' => 1, 'log' => 'log' }) }

  before :each do
    Job::Test.stubs(:find).returns(test)
    Artifact::Log.stubs(:append)
    test.stubs(:notify)
  end

  it 'finds the job' do
    Job::Test.expects(:find).with(1).returns(test)
    service.run
  end

  it 'appends the log' do
    Artifact::Log.stubs(:append).with('log')
    service.run
  end

  it 'notifies observers' do
    test.expects(:notify).with(:log, _log: 'log')
    service.run
  end
end
