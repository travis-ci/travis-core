require 'spec_helper'

describe Travis::Services::UpdateWorkers do
  include Support::Redis

  let(:reports) do
    [
      { 'name' => 'ruby-1', 'host' => 'ruby.workers.travis-ci.org', 'state' => 'working', 'payload' => { 'job' => { 'id' => 123 }, 'repository' => { 'id' => 1 } } },
      { 'name' => 'ruby-2', 'host' => 'ruby.workers.travis-ci.org', 'state' => 'ready',   'payload' => { 'job' => { 'id' => 124 }, 'repository' => { 'id' => 1 } } },
      { 'name' => 'ruby-3', 'host' => 'ruby.workers.travis-ci.org', 'state' => 'ready',   'payload' => { 'job' => { 'id' => 125 }, 'repository' => { 'id' => 1 } } }
    ]
  end

  let(:service) { described_class.new(reports: reports) }

  before :each do
    Worker.create(full_name: 'ruby.workers.travis-ci.org:ruby-1', state: :ready, payload: { 'job' => { 'id' => 123 }})
    Worker.create(full_name: 'ruby.workers.travis-ci.org:ruby-2', state: :ready, payload: { 'job' => { 'id' => 124 }})
    Worker.any_instance.stubs(:notify)
  end

  def ttls
    Worker.all.map { |worker| Worker.ttl(worker.id) }
  end

  it 'creates a worker record if missing' do
    lambda { service.run }.should change(Worker, :count).by(1)
  end

  it "updates each worker record's expiration time" do
    sleep 1
    ttls.should == [59, 59]
    service.run
    ttls.should == [60, 60, 60]
  end

  it "updates each worker record's :state attribute" do
    service.run
    Worker.all.map(&:state).should == ['working', 'ready', 'ready']
  end

  it 'notifies about the worker creation' do
    Worker.any_instance.expects(:notify).with(:add).once
    service.run
  end

  it 'notifies about worker state changes' do
    Worker.any_instance.expects(:notify).with(:update).once
    service.run
  end

  it "does not update if the state does not change" do
    reports.first.merge!('state' => 'ready')
    Worker.any_instance.expects(:update_attributes).never
    service.run
  end

  it "updates if the job changes, even if the state does not change" do
    reports.first.merge!('payload' => { 'job' => { 'id' => 1234 } })
    Worker.any_instance.expects(:update_attributes).once
    service.run
  end

  it "does not notify if the state does not change" do
    reports.first.merge!('state' => 'ready')
    Worker.any_instance.expects(:notify).with(:update).never
    service.run
  end

  it 'does not save config along with payload' do
    reports.first['payload'].merge!('config' => { 'bar' => 'baz' })
    service.run
    Worker.all.each { |worker| worker.payload['config'].should be_blank }
  end
end

