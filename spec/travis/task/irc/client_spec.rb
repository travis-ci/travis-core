require 'spec_helper'

describe Travis::Task::Irc::Client do
  let(:socket)   { stub(:puts => true, :get => true, :eof? => true) }
  let(:server)   { 'irc.freenode.net' }
  let(:nick)     { 'travis_bot' }
  let(:channel)  { 'travis' }
  let(:password) { 'secret' }
  let(:ping)     { 'testping' }

  describe 'on initialization' do
    describe 'with no port specified' do
      it 'should open a socket on the server for port 6667' do
        TCPSocket.expects(:open).with(server, 6667).returns socket
        Travis::Task::Irc::Client.new(server, nick)
      end
    end

    describe 'with port specified' do
      it 'should open a socket on the server for the given port' do
        TCPSocket.expects(:open).with(server, 1234).returns socket
        Travis::Task::Irc::Client.new(server, nick, :port => 1234)
      end
    end

    describe 'should connect to the server' do
      before do
        @socket = mock
        TCPSocket.stubs(:open).returns @socket
      end

      def expect_standard_sequence
        @socket.expects(:puts).with("NICK #{nick}")
        @socket.expects(:puts).with("USER #{nick} #{nick} #{nick} :#{nick}")
      end

      describe 'without a password' do
        it 'by sending NICK then USER' do
          expect_standard_sequence
          Travis::Task::Irc::Client.new(server, nick)
        end
      end

      describe 'with a password' do
        it 'by sending PASS then NICK then USER' do
          @socket.expects(:puts).with("PASS #{password}")
          expect_standard_sequence
          Travis::Task::Irc::Client.new(server, nick, :password => password)
        end
      end
    end

    describe 'should connect to a server which requires ping/pong' do
      before do
        @socket = mock
        TCPSocket.stubs(:open).returns @socket
        @socket.stubs(:gets).returns("PING #{ping}").then.returns ""
      end

      def expect_standard_sequence
        @socket.expects(:puts).with("NICK #{nick}")
        @socket.expects(:puts).with("USER #{nick} #{nick} #{nick} :#{nick}")
        @socket.expects(:puts).with("PONG #{ping}")
      end

      describe "without a password" do
        it 'by sending NICK then USER' do
          expect_standard_sequence
          Travis::Task::Irc::Client.new(server, nick)
          # this sleep is here so that the ping thread has a chance to run
          sleep 0.5
        end
      end

    end
  end

  describe 'with connection established' do
    let(:socket) { stub(:puts => true) }
    let(:channel_key) { 'mykey' }

    before(:each) do
      TCPSocket.stubs(:open).returns socket
      @client = Travis::Task::Irc::Client.new(server, nick)
    end

    it 'can message a channel before joining' do
      socket.expects(:puts).with("PRIVMSG #travis :hello")
      @client.say 'hello', 'travis'
    end

    it 'can notice a channel before joining' do
      socket.expects(:puts).with("NOTICE #travis :hello")
      @client.say 'hello', 'travis', true
    end

    it 'can join a channel' do
      socket.expects(:puts).with("JOIN ##{channel}")
      @client.join(channel)
    end

    it 'can join a channel with a key' do
      socket.expects(:puts).with("JOIN ##{channel} mykey")
      @client.join(channel, 'mykey')
    end

    describe 'and channel joined' do
      before(:each) do
        @client.join(channel)
      end
      it 'can leave the channel' do
        socket.expects(:puts).with("PART ##{channel}")
        @client.leave(channel)
      end
      it 'can message the channel' do
        socket.expects(:puts).with("PRIVMSG ##{channel} :hello")
        @client.say 'hello', channel
      end
      it 'can notice the channel' do
        socket.expects(:puts).with("NOTICE ##{channel} :hello")
        @client.say 'hello', channel, true
      end
    end

    it 'can run a series of commands' do
      socket.expects(:puts).with("JOIN #travis")
      socket.expects(:puts).with("PRIVMSG #travis :hello")
      socket.expects(:puts).with("NOTICE #travis :hi")
      socket.expects(:puts).with("PRIVMSG #travis :goodbye")
      socket.expects(:puts).with("PART #travis")

      @client.run do |client|
        client.join 'travis'
        client.say 'hello', 'travis'
        client.say 'hi', 'travis', true
        client.say 'goodbye', 'travis'
        client.leave 'travis'
      end
    end

    it 'can abandon the connection' do
      socket.expects(:puts).with("QUIT")
      socket.expects(:eof?).returns(true)
      socket.expects(:close)
      @client.quit
    end
  end
end
