require 'spec_helper'

describe Worker::Repository do
  include Support::Redis

  let(:payload)   { { job: { id: 1 }, repository: { id: 1, slug: 'foo/bar' } } }
  let(:full_name) { 'worker-1.travis-ci.org:ruby-1' }
  let(:worker)    { create_worker }
  let(:workers)   { [create_worker(full_name: 'one'), create_worker(full_name: 'two')] }

  def create_worker(attrs = {})
    Worker::Repository.create({ full_name: full_name, state: 'started', payload: payload }.merge(attrs))
  end

  describe 'create' do
    it 'stores the record to redis' do
      data = redis.get("worker-#{worker.id}")
      MultiJson.load(data)['full_name'].should == full_name
    end

    it 'generates a random id' do
      worker.id.should =~ /[a-z0-9]+/i
    end

    it 'registers the worker' do
      redis.sismember('workers', worker.id).should be_true
    end

    it 'notifies observers' do
      Travis::Event.expects(:dispatch).with { |event| event == 'worker:added' }
      worker
    end
  end

  describe 'all' do
    it 'returns worker instances' do
      workers
      Worker::Repository.all.should == workers
    end
  end

  describe 'count' do
    it 'returns the number of workers' do
      workers
      Worker::Repository.count.should == 2
    end
  end

  describe 'find' do
    it 'finds a record by the given id' do
      worker = self.worker
      Worker::Repository.find(worker.id).should == worker
    end

    it 'returns nil if the record can not be found' do
      Worker::Repository.find(1).should be_nil
    end
  end

  describe 'update' do
    it 'updates the record with the given attributes' do
      Worker::Repository.update(worker.id, state: 'waiting')
      Worker::Repository.find(worker.id).state.should == 'waiting'
    end
  end
end
