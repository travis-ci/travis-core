require 'spec_helper'

describe Worker::Status do
  include Support::ActiveRecord

  let(:reports) do
    [
      { 'name' => 'ruby-1', 'host' => 'ruby.workers.travis-ci.org', 'state' => 'working', 'payload' => { 'foo' => 'bar' } },
      { 'name' => 'ruby-2', 'host' => 'ruby.workers.travis-ci.org', 'state' => 'ready' },
      { 'name' => 'ruby-3', 'host' => 'ruby.workers.travis-ci.org', 'state' => 'ready' }
    ]
  end

  let(:status) { Worker::Status.new(reports) }

  before :each do
    Worker.create!(:name => 'ruby-1', :host => 'ruby.workers.travis-ci.org', :state => :ready, :last_seen_at => Time.now - 10)
    Worker.create!(:name => 'ruby-2', :host => 'ruby.workers.travis-ci.org', :state => :ready, :last_seen_at => Time.now - 10)
  end

  it 'creates a worker record if missing' do
    lambda { status.run }.should change(Worker, :count).by(1)
  end

  it "updates each worker record's :last_seen_at attribute" do
    status.run
    Worker.all.map(&:last_seen_at).uniq.map(&:to_s).should == [Time.now.to_s]
  end

  it "updates each worker record's :state attribute" do
    status.run
    Worker.all.map(&:state).sort.should == ['ready', 'ready', 'working']
  end

  it 'notifies about the worker creation' do
    Worker.any_instance.stubs(:notify)
    Worker.any_instance.expects(:notify).with(:add).once
    status.run
  end

  it 'notifies about worker state changes' do
    Worker.any_instance.stubs(:notify)
    Worker.any_instance.expects(:notify).with(:update).once
    status.run
  end
end

