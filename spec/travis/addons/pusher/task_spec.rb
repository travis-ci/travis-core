# encoding: utf-8
require 'spec_helper'

describe Travis::Addons::Pusher::Task do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Pusher::Task }
  let(:channel) { Support::Mocks::Pusher::Channel.new }

  before do
    Travis.config.notifications = [:pusher]
    Travis.pusher.stubs(:[]).returns(channel)
  end

  def run(event, object, options = {})
    version = options[:version] || 'v1'
    type = event =~ /^worker:/ ? 'worker' : event.sub('test:', '').sub(':', '/')
    payload = Travis::Api.data(object, for: 'pusher', type: type, version: version, params: options[:params])
    subject.new(payload, event: event, version: version).run
  end

  it 'logs Pusher errors and reraises' do
    channel.expects(:trigger_async).raises(Pusher::Error.new('message'))
    payload = Travis::Api.data(test, for: 'pusher', type: 'job/started', version: 'v1').deep_symbolize_keys
    Travis.logger.expects(:error).with("[addons:pusher] Could not send event due to Pusher::Error: message, event=job:started, payload: #{payload.inspect}")

    expect { run('job:test:started', test) }.to raise_error(Pusher::Error)
  end

  it 'warns when log needs to be split' do
    subject.stubs(:chunk_size => 5)
    Travis.logger.expects(:warn) { |message| message =~ /\[addons:pusher\] The log part from worker was bigger than 9kB/ }

    run('job:test:log', test, params: { _log: "123456" })

    channel.messages.length.should == 2
  end

  it 'splits log messages into chunks, to not exceed the limit in bytes' do
    subject.stubs(:chunk_size => 5)
    run('job:test:log', test, params: { _log: "0000\ną" })

    channel.messages.length.should == 3
    channel.messages.map { |message| message[1][:_log] }.should == ["000", "0\n", "ą"]
  end

  it 'sets separate numbers for each chunk' do
    subject.stubs(:chunk_size => 5)
    run('job:test:log', test, params: { _log: "0000\ną", number: 3 })

    channel.messages.length.should == 3
    channel.messages.map { |message| message[1][:number] }.should == [3, '3.1', '3.2']
    channel.messages.map { |message| message[1][:final] }.should == [nil, nil, nil]
  end

  it 'sets final only for the last of the chunks' do
    subject.stubs(:chunk_size => 5)
    run('job:test:log', test, params: { _log: "0000\ną", final: true })

    channel.messages.length.should == 3
    channel.messages.map { |message| message[1][:final] }.should == [false, false, true]
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

    it 'build:created' do
      run('build:created', build)
      channel.should have_message('build:created', build)
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

  describe 'channels' do
    it 'returns "common" for the event "job:created"' do
      payload = Travis::Api.data(test, for: 'pusher', type: 'job/created', version: 'v1')
      handler = subject.new(payload, event: 'job:created')
      handler.send(:channels).should include('common')
    end

    it 'returns "common" for the event "job:started"' do
      payload = Travis::Api.data(test, for: 'pusher', type: 'job/started', version: 'v1')
      handler = subject.new(payload, event: 'job:started')
      handler.send(:channels).should include('common')
    end

    it 'returns "job-1" for the event "job:log"' do
      payload = Travis::Api.data(test, for: 'pusher', type: 'job/log', version: 'v1')
      handler = subject.new(payload, event: 'job:log')
      handler.send(:channels).should include("job-#{test.id}")
    end

    it 'returns "common" for the event "job:finished"' do
      payload = Travis::Api.data(test, for: 'pusher', type: 'job/finished', version: 'v1')
      handler = subject.new(payload, event: 'job:finished')
      handler.send(:channels).should include('common')
    end

    it 'returns "common" for the event "build:started"' do
      payload = Travis::Api.data(build, for: 'pusher', type: 'build/started', version: 'v1')
      handler = subject.new(payload, event: 'build:started')
      handler.send(:channels).should include('common')
    end

    it 'returns "common" for the event "build:finished"' do
      payload = Travis::Api.data(build, for: 'pusher', type: 'build/finished', version: 'v1')
      handler = subject.new(payload, event: 'build:finished')
      handler.send(:channels).should include('common')
    end

    it 'returns "common" for the event "worker:started"' do
      payload = Travis::Api.data(worker, for: 'pusher', type: 'worker', version: 'v1')
      handler = subject.new(payload, event: 'worker:created')
      handler.send(:channels).should include('common')
    end
  end

  it 'does not prefix channels for version v1' do
    run('job:test:created', test, version: 'v1')
    channel.should have_message('job:created', test)
  end

  it 'prefixes channels for other versions' do
    run('job:test:created', test, version: 'v2')
    channel.should have_message('v2:job:created', test)
  end
end
