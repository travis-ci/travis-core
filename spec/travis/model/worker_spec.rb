require 'spec_helper'

describe Worker do
  include Support::Redis

  let(:payload)   { { job: { id: 1 }, repository: { id: 1, slug: 'foo/bar' } } }
  let(:full_name) { 'worker-1.travis-ci.org:ruby-1' }
  let(:state)     { 'started' }
  let(:worker)    { create_worker }

  def create_worker(attrs = {})
    Worker::Repository.create({ full_name: full_name, state: state, payload: payload }.merge(attrs))
  end

  describe 'attributes' do
    it 'full_name' do
      worker.full_name.should == full_name
    end

    it 'state' do
      worker.state.should == state
    end

    it 'payload' do
      worker.payload.should == payload
    end

    it 'host' do
      worker.host.should == 'worker-1.travis-ci.org'
    end

    it 'name' do
      worker.name.should == 'ruby-1'
    end
  end

  describe 'guess_queue' do
    it 'guesses the queue name "builds.common" (ruby)' do
      Worker.new(nil, full_name: 'something.with.ruby').guess_queue.should == 'builds.common'
    end

    it 'guesses the queue name "builds.common" (staging)' do
      Worker.new(nil, full_name: 'something.on.staging').guess_queue.should == 'builds.common'
    end

    it 'guesses the queue name "builds.php" (ppp)' do
      Worker.new(nil, full_name: 'something.with.ppp').guess_queue.should == 'builds.php'
    end

    it 'guesses the queue name "builds.php" (php)' do
      Worker.new(nil, full_name: 'something.with.php').guess_queue.should == 'builds.php'
    end

    it 'guesses the queue name "builds.jvmotp"' do
      Worker.new(nil, full_name: 'something.with.jvm-opt').guess_queue.should == 'builds.jvmotp'
    end

    it 'guesses the queue name "builds.rails"' do
      Worker.new(nil, full_name: 'something.with.rails').guess_queue.should == 'builds.rails'
    end
  end
end

