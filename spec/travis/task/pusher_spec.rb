require 'spec_helper'

describe Travis::Task::Pusher do
  include Support::ActiveRecord
  include Support::Stubs

  let(:channel) { Support::Mocks::Pusher::Channel.new }

  before do
    Travis.config.notifications = [:pusher]
    Pusher.stubs(:[]).returns(channel)
  end

  def run(event, object)
    type = event =~ /^worker:/ ? 'worker' : event.sub('test:', '').sub(':', '/')
    data = Travis::Api.data(object, :for => 'pusher', :type => type, :version => 'v1')
    Travis::Task::Pusher.new(event, data).run
  end

  describe 'run' do
    it 'job:test:created' do
      run('job:test:created', test)
      channel.should have_message('job:created', test)
    end

    it 'job:test:started' do
      run('job:test:started', test)
      channel.should have_message('job:started', test)
    end

    it 'job:log' do
      run('job:test:log', test)
      channel.should have_message('job:log', test)
    end

    it 'job:test:finished' do
      run('job:test:finished', test)
      channel.should have_message('job:finished', test)
    end

    it 'build:started' do
      run('build:started', build)
      channel.should have_message('build:started', build)
    end

    it 'build:finished' do
      run('build:finished', build)
      channel.should have_message('build:finished', build)
    end

    it 'worker:started' do
      run('worker:started', worker)
      channel.should have_message('worker:started', worker)
    end
  end

  describe 'channels_for' do
    let(:handler) { Travis::Task::Pusher.new('event', test) }

    it 'returns "common" for the event "job:created"' do
      handler.send(:channels_for, 'job:created', test).should include('common')
    end

    it 'returns "common" for the event "job:started"' do
      handler.send(:channels_for, 'job:started', test).should include('common')
    end

    it 'returns "job-1" for the event "job:log"' do
      data = Travis::Api.data(test, :for => 'pusher', :type => 'job/log', :version => 'v1')
      handler.send(:channels_for, 'job:log', data).should include("job-#{test.id}")
    end

    it 'returns "common" for the event "job:finished"' do
      handler.send(:channels_for, 'job:finished', test).should include('common')
    end

    it 'returns "common" for the event "build:started"' do
      handler.send(:channels_for, 'build:started', build).should include('common')
    end

    it 'returns "common" for the event "build:finished"' do
      handler.send(:channels_for, 'build:finished', build).should include('common')
    end

    it 'returns "common" for the event "worker:started"' do
      handler.send(:channels_for, 'worker:created', build).should include('common')
    end
  end
end
