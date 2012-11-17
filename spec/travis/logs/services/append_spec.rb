require 'spec_helper'
require 'travis/logs/services/append'

describe Travis::Logs::Services::Append do
  include Travis::Testing::Stubs

  let(:service) { described_class.new('data' => { 'id' => 1, 'log' => 'foo' }) }

  before :each do
    Job::Test.stubs(:find).returns(test)
    test.stubs(:append_log!)
  end

  it 'finds the job' do
    Job::Test.expects(:find).with(1).returns(test)
    service.run
  end

  it 'appends the log' do
    test.expects(:append_log!).with('foo')
    service.run
  end
end

