require 'spec_helper'

describe Travis::Logs::Services::Receive do
  include Support::ActiveRecord, Support::Silence

  let(:job)     { Factory.create(:test, log: Factory.create(:log, content: '')) }
  let!(:log)    { job.log }
  let(:data)    { { 'id' => job.id, 'log' => 'log', 'number' => 1, 'final' => false } }
  let(:service) { described_class.new('data' => data) }

  it 'creates a log part with the given number' do
    service.run
    log.parts.first.content.should == 'log'
  end

  it 'filters out null chars' do
    data.update('log' => "a\0b\0c")
    service.run
    log.parts.first.content.should == 'abc'
  end

  it 'filters out triple null chars' do
    data.update('log' => "a\000b\000c")
    service.run
    log.parts.first.content.should == 'abc'
  end

  it 'does not set the :final flag if the appended message does not contain the final log message part' do
    service.run
    log.parts.first.final.should be_false
  end

  it 'sets the :final flag if the appended message contains the final log message part' do
    data.update('log' => "some log.\n#{described_class::FINAL} result")
    service.run
    log.parts.first.final.should be_true
  end

  it 'notifies observers' do
    Job::Test.stubs(:find).with(job.id).returns(job)
    job.expects(:notify).with(:log, _log: 'log', number: 1, final: false)
    service.run
  end

  it "doesn't reraise an error when notifications failed" do
    Job::Test.stubs(:find).with(job.id).returns(job)
    job.expects(:notify).raises(StandardError.new)
    
    expect {
      service.run
    }.to_not raise_error
  end

  it "tracks a metric when notifications failed" do
    Job::Test.stubs(:find).with(job.id).returns(job)
    job.expects(:notify).raises(StandardError.new)
    
    expect {
      service.run
    }.to change {Metriks.meter('travis.logs.update.notify.errors').count}
  end

  it 'creates a log if missing (should never happen, but does)' do
    log.destroy
    silence { service.run }
    job.reload.log.parts.first.content.should == 'log'
  end
end
