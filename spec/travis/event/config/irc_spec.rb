require 'spec_helper'
require 'travis/event/config/spec_helper'

describe Travis::Event::Config::Irc do
  include Travis::Testing::Stubs

  let(:config) { Travis::Event::Config::Irc.new(build) }

  describe :send_on_finish? do
    before :each do
      build.stubs(:config => { :notifications => { :irc => 'irc.freenode.net#travis' } })
    end

    it_behaves_like 'a build configuration'
  end

  describe :channels do
    it 'returns an array of urls when given a string' do
      channels = 'irc.freenode.net#travis'
      build.stubs(:config => { :notifications => { :irc => channels } })
      config.channels.should == { ['irc.freenode.net', nil] => ['travis'] }
    end

    it 'returns an array of urls when given an array' do
      channels = ['irc.freenode.net#travis', 'irc.freenode.net#rails']
      build.stubs(:config => { :notifications => { :irc => channels } })
      config.channels.should == { ['irc.freenode.net', nil] => ['travis', 'rails'] }
    end

    it 'returns an array of urls when given a string on the channels key' do
      channels = 'irc.freenode.net#travis'
      build.stubs(:config => { :notifications => { :irc => { :channels => channels } } })
      config.channels.should == { ['irc.freenode.net', nil] => ['travis'] }
    end

    it 'returns an array of urls when given an array on the channels key' do
      channels = ['irc.freenode.net#travis', 'irc.freenode.net#rails']
      build.stubs(:config => { :notifications => { :irc => { :channels => channels } } })
      config.channels.should == { ['irc.freenode.net', nil] => ['travis', 'rails'] }
    end

    it 'groups irc channels by host & port, so notifications can be sent with one connection' do
      build.stubs(:config => { :notifications => { :irc => %w(
        irc.freenode.net:1234#travis
        irc.freenode.net#rails
        irc.freenode.net:1234#travis-2
        irc.example.com#travis-3
      )}})
      config.channels.should == {
        ["irc.freenode.net", '1234'] => ['travis', 'travis-2'],
        ["irc.freenode.net", nil]    => ['rails'],
        ["irc.example.com",  nil]    => ['travis-3']
      }
    end
  end
end
