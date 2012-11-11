require 'spec_helper'

describe Travis::Notification::Publisher::Log do
  include Support::Notifications

  let(:io) { StringIO.new }
  let(:log) { io.string }

  before do
    Travis.logger = Logger.new(io)
    Travis.logger.level = Logger::INFO
  end

  it 'writes to Travis.logger' do
    log.should be_empty
    publish
    log.should_not be_empty
  end

  it 'prints out the :msg value' do
    publish msg: 'FOO BAR'
    log.should include('Object#instrumented FOO BAR')
  end

  it 'defaults to INFO' do
    publish(msg: 'foo bar')
    log.should include('I Object#instrumented foo bar')
  end

  it 'uses ERROR if an exception occured' do
    instrument(exception: true).publish(msg: 'foo bar')
    log.should include('E Object#instrumented foo bar')
  end

  it 'does not include extra information if no exception occured' do
    publish(foo: 'bar')
    log.should_not include("foo: 'bar'")
  end

  # it 'does include extra information if no exception occured but log level is DEBUG' do
  #   Travis.logger.level = Logger::DEBUG
  #   log.should include("foo: \"bar\"")
  # end

  it 'does include extra information if an exception occured' do
    instrument(exception: true).publish(foo: 'bar')
    log.should include("\"bar\"")
  end
end
