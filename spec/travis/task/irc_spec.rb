require 'spec_helper'

describe Travis::Task::Irc do
  include Support::ActiveRecord
  include Travis::Testing::Stubs

  let(:tcp)      { stub('tcp', eof?: true, close: true) }
  let(:seq)      { sequence('tcp') }
  let(:channels) { ['irc.freenode.net:1234#travis'] }
  let(:payload)  { Travis::Api.data(build, for: 'event', version: 'v0') }

  before do
    Travis::Features.start
    Travis::Features.stubs(:active?).returns(true)
    Travis.config.notifications = [:irc]
    Repository.stubs(:find).returns(stub('repo'))
    Url.stubs(:shorten).returns(url)
  end

  def expect_irc(host, port, channel, messages)
    TCPSocket.expects(:open).with(host, port).in_sequence(seq).returns(tcp)
    messages.each { |message| tcp.expects(:puts).with(message).in_sequence(seq) }
  end

  def run(channels = nil)
    Travis::Task::Irc.new(payload, channels: channels || self.channels).run
  end

  let(:simple_irc_notfication_messages) do
    [
      'NICK travis-ci',
      'USER travis-ci travis-ci travis-ci :travis-ci',
      'JOIN #travis',
      'PRIVMSG #travis :[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.',
      'PRIVMSG #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      'PRIVMSG #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/minimal/builds/1',
      'PART #travis',
      'QUIT'
    ]
  end

  it 'one irc notification' do
    expect_irc 'irc.freenode.net', 1234, 'travis', simple_irc_notfication_messages
    run
  end

  it 'one irc notification using notice' do
    payload['build']['config']['notifications'] = { irc: { use_notice: true } }

    expect_irc 'irc.freenode.net', 1234, 'travis', [
      'NICK travis-ci',
      'USER travis-ci travis-ci travis-ci :travis-ci',
      'JOIN #travis',
      'NOTICE #travis :[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.',
      'NOTICE #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      'NOTICE #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/minimal/builds/1',
      'PART #travis',
      'QUIT'
    ]
    run
  end

  it 'one irc notification without joining the channel' do
    payload['build']['config']['notifications'] = { irc: { skip_join: true } }

    expect_irc 'irc.freenode.net', 1234, 'travis', [
      'NICK travis-ci',
      'USER travis-ci travis-ci travis-ci :travis-ci',
      'PRIVMSG #travis :[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.',
      'PRIVMSG #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      'PRIVMSG #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/minimal/builds/1',
      'QUIT'
    ]
    run
  end

  it 'with a custom message template' do
    payload['build']['config']['notifications'] = { irc: { template: '%{repository} %{commit}' } }

    expect_irc 'irc.freenode.net', 1234, 'travis', [
      'NICK travis-ci',
      'USER travis-ci travis-ci travis-ci :travis-ci',
      'JOIN #travis',
      'PRIVMSG #travis :[travis-ci] svenfuchs/minimal 62aae5f',
      'PART #travis',
      'QUIT'
    ]
    run
  end

  it 'with multiple custom message templates' do
    payload['build']['config']['notifications'] = { irc: { template: ['%{repository} %{commit}', '%{message}'] } }

    expect_irc 'irc.freenode.net', 1234, 'travis', [
      'NICK travis-ci',
      'USER travis-ci travis-ci travis-ci :travis-ci',
      'JOIN #travis',
      'PRIVMSG #travis :[travis-ci] svenfuchs/minimal 62aae5f',
      'PRIVMSG #travis :[travis-ci] The build passed.',
      'PART #travis',
      'QUIT'
    ]
    run
  end

  it 'with two irc notifications to different hosts' do
    [['irc.freenode.net', 1234, 'travis'], ['irc.example.com', 6667, 'example']].each do |host, port, channel|
      expect_irc host, port, channel, [
        'NICK travis-ci',
        'USER travis-ci travis-ci travis-ci :travis-ci',
        "JOIN ##{channel}",
        "PRIVMSG ##{channel} :[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.",
        "PRIVMSG ##{channel} :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop",
        "PRIVMSG ##{channel} :[travis-ci] Build details : http://travis-ci.org/svenfuchs/minimal/builds/1",
        "PART ##{channel}",
        'QUIT'
      ]
    end
    run(['irc.freenode.net:1234#travis', 'irc.example.com:6667#example'])
  end

  it 'does not disconnect for notifications to channels on the same host' do
    expect_irc 'irc.example.com', 6667, 'travis', [
      'NICK travis-ci',
      'USER travis-ci travis-ci travis-ci :travis-ci',
      'JOIN #travis',
      'PRIVMSG #travis :[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.',
      'PRIVMSG #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      'PRIVMSG #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/minimal/builds/1',
      'PART #travis',
      'JOIN #example',
      'PRIVMSG #example :[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.',
      'PRIVMSG #example :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      'PRIVMSG #example :[travis-ci] Build details : http://travis-ci.org/svenfuchs/minimal/builds/1',
      'PART #example',
      'QUIT'
    ]
    run(['irc.example.com:6667#travis', 'irc.example.com:6667#example'])
  end

  it 'sets a connection password' do
    payload['build']['config']['notifications'] = { irc: { use_notice: true, password: 'pass' } }

    expect_irc 'irc.freenode.net', 1234, 'travis', [
      'PASS pass',
      'NICK travis-ci',
      'USER travis-ci travis-ci travis-ci :travis-ci',
      'JOIN #travis',
      'NOTICE #travis :[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.',
      'NOTICE #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      'NOTICE #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/minimal/builds/1',
      'PART #travis',
      'QUIT'
    ]
    run
  end

  it 'message nickserv with a nickserv password' do
    payload['build']['config']['notifications'] = { irc: { use_notice: true, password: 'pass', nickserv_password: 'nickpass' } }

    expect_irc 'irc.freenode.net', 1234, 'travis', [
      'PASS pass',
      'NICK travis-ci',
      'PRIVMSG NickServ :IDENTIFY nickpass',
      'USER travis-ci travis-ci travis-ci :travis-ci',
      'JOIN #travis',
      'NOTICE #travis :[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.',
      'NOTICE #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      'NOTICE #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/minimal/builds/1',
      'PART #travis',
      'QUIT'
    ]
    run
  end

  it 'allows overwriting the nickname' do
    payload['build']['config']['notifications'] = { irc: { use_notice: true, nick: 'nick', password: 'pass', nickserv_password: 'nickpass' } }

    expect_irc 'irc.freenode.net', 1234, 'travis', [
      'PASS pass',
      'NICK nick',
      'PRIVMSG NickServ :IDENTIFY nickpass',
      'USER nick nick nick :nick',
      'JOIN #travis',
      'NOTICE #travis :[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.',
      'NOTICE #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      'NOTICE #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/minimal/builds/1',
      'PART #travis',
      'QUIT'
    ]
    run
  end

  it 'works with just a list of channels' do
    payload['build']['config']['notifications'] = {}

    expect_irc 'irc.freenode.net', 1234, 'travis', [
      'NICK travis-ci',
      'USER travis-ci travis-ci travis-ci :travis-ci',
      'JOIN #travis',
      'PRIVMSG #travis :[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.',
      'PRIVMSG #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      'PRIVMSG #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/minimal/builds/1',
      'PART #travis',
      'QUIT'
    ]
    run
  end

  it 'wrap socket with ssl (in client private) when configured to IRC+SSL server' do
    Travis::Task::Irc::Client.expects(:wrap_ssl).with(tcp).returns(tcp)
    expect_irc 'irc.freenode.net', 1234, 'travis', simple_irc_notfication_messages
    run(['ircs://irc.freenode.net:1234#travis'])
  end

  describe 'parsed_channels' do
    it 'groups irc channels by host, port & ssl flag, so notifications can be sent with one connection' do
      channels = %w(
        irc.freenode.net:1234#travis
        irc.freenode.net#rails
        irc.freenode.net:1234#travis-2
        irc.example.com#travis-3
        ircs://irc.example.com:2345#travis-4
        irc://irc.freenode.net:1234#travis-5
      )
      handler = Travis::Task::Irc.new(payload, channels: channels)
      handler.send(:parsed_channels).should == {
        ['irc.freenode.net', 1234, nil]  => ['travis', 'travis-2', 'travis-5'],
        ['irc.freenode.net', nil,  nil]  => ['rails'],
        ['irc.example.com',  nil,  nil]  => ['travis-3'],
        ['irc.example.com',  2345, :ssl] => ['travis-4']
      }
    end
  end
end
