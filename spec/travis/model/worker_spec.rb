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

  describe 'queue' do
    it 'returns the queue if given' do
      Worker.new(nil, queue: 'builds.nodejs').queue.should == 'builds.nodejs'
    end

    it 'guesses the queue if not given' do
      Worker.new(nil, full_name: 'something.with.ruby').queue.should == 'builds.linux'
    end
  end

  describe 'guess_queue' do
    it 'guesses the queue name "builds.linux" (ruby)' do
      Worker.new(nil, full_name: 'something.with.ruby').guess_queue.should == 'builds.linux'
    end

    it 'guesses the queue name "builds.linux" (staging)' do
      Worker.new(nil, full_name: 'something.on.staging').guess_queue.should == 'builds.linux'
    end

    it 'guesses the queue name "builds.linux" (linux)' do
      Worker.new(nil, full_name: 'bluebox-linux-1.worker').guess_queue.should == 'builds.linux'
    end

    it 'guesses the queue name "builds.mac_osx" (mac)' do
      Worker.new(nil, full_name: 'saucelabs-mac.worker').guess_queue.should == 'builds.mac_osx'
    end
  end
end

