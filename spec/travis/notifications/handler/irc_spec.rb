require 'spec_helper'
require 'support/active_record'
require 'support/mocks/irc'

describe Travis::Notifications::Handler::Irc do
  include Support::ActiveRecord

  attr_reader :irc

  before do
    @irc = Support::Mocks::Irc.new
    TCPSocket.any_instance.stubs(:puts => true, :get => true, :eof? => true)
    Travis.config.notifications = [:irc]
  end

  let(:repository) { Factory(:repository, :owner_email => 'owner@example.com') }
  let(:config_with_customized_template) {{ 'notifications' => { 'irc' => "irc.freenode.net:1234#travis", 'template' => ["%{repository_url} (%{commit}): %{message} %{foo} "] } }}

  def expect_irc(host, options = {}, count = 1)
    IrcClient.expects(:new).times(count).with(host, 'travis-ci', { :port => nil }.merge(options)).returns(irc)
  end

  it "no irc notifications" do
    build = Factory(:build)
    IrcClient.expects(:new).never
    Travis::Notifications.dispatch('build:finished', build)
  end

  it "one irc notification" do
    build = Factory(:successful_build, :config => { 'notifications' => { 'irc' => "irc.freenode.net:1234#travis" } })

    expect_irc('irc.freenode.net', { :port => '1234' })

    Travis::Notifications::Handler::Irc.new.notify('build:finished', build)

    expected = [
      'JOIN #travis',
      'PRIVMSG #travis :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      'PRIVMSG #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      "PRIVMSG #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}",
      'PART #travis',
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end

  it "one irc notification using notice" do
    build = Factory(:successful_build, :config => { 'notifications' => { 'irc' => { 'use_notice' => true, 'channels' => ["irc.freenode.net:1234#travis"] } } })

    expect_irc('irc.freenode.net', { :port => '1234' })

    Travis::Notifications::Handler::Irc.new.notify('build:finished', build)

    expected = [
      'JOIN #travis',
      'NOTICE #travis :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      'NOTICE #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      "NOTICE #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}",
      'PART #travis',
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end

  it "one irc notification without joining the channel" do
    build = Factory(:successful_build, :config => { 'notifications' => { 'irc' => { 'skip_join' => true, 'channels' => ["irc.freenode.net:1234#travis"] } } })

    expect_irc('irc.freenode.net', { :port => '1234' })

    Travis::Notifications::Handler::Irc.new.notify('build:finished', build)

    expected = [
      'PRIVMSG #travis :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      'PRIVMSG #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      "PRIVMSG #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}",
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end

  it "wiil post the irc notification with a customized message" do
    build = Factory(:successful_build, :config => config_with_customized_template)

    expect_irc('irc.freenode.net', { :port => '1234' })

    Travis::Notifications::Handler::Irc.new.notify('build:finished', build)

    expected = [
      'JOIN #travis',
      'PRIVMSG #travis :[travis-ci] svenfuchs/successful_build (62aae5f70ceee39123ef): The build passed.',
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end

  it "two irc notifications to different hosts, using config with notification rules" do
    config = { 'notifications' => { 'irc' => { 'skip_join' => false, 'on_success' => "always", 'channels' => ["irc.freenode.net:1234#travis", "irc.example.com#example"] } } }
    build  = Factory(:successful_build, :config => config)

    expect_irc('irc.freenode.net', { :port => '1234' })
    expect_irc('irc.example.com')

    Travis::Notifications::Handler::Irc.new.notify('build:finished', build)

    expected = [
      'JOIN #travis',
      'PRIVMSG #travis :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      'PRIVMSG #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      "PRIVMSG #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}",
      "PART #travis",
      "QUIT",
      'JOIN #example',
      'PRIVMSG #example :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      'PRIVMSG #example :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      "PRIVMSG #example :[travis-ci] Build details : http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}",
      'PART #example',
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end

  it "two irc notifications to different hosts, using config with notification rules, without joining channel" do
    config = { 'notifications' => { 'irc' => { 'skip_join' => true, 'on_success' => "always", 'channels' => ["irc.freenode.net:1234#travis", "irc.example.com#example"] } } }
    build  = Factory(:successful_build, :config => config)

    expect_irc('irc.freenode.net', { :port => '1234' })
    expect_irc('irc.example.com')

    Travis::Notifications::Handler::Irc.new.notify('build:finished', build)

    expected = [
      'PRIVMSG #travis :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      'PRIVMSG #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      "PRIVMSG #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}",
      "QUIT",
      'PRIVMSG #example :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      'PRIVMSG #example :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      "PRIVMSG #example :[travis-ci] Build details : http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}",
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end

  it "irc notifications to the same host should not disconnect between notifications" do
    config = { 'notifications' => { 'irc' => ["irc.freenode.net:6667#travis", "irc.freenode.net:6667#rails", "irc.example.com#example"] } }
    build  = Factory(:broken_build, :config => config)

    expect_irc('irc.freenode.net', { :port => '6667' }, 1) # (Only connect once to irc.freenode.net)
    expect_irc('irc.example.com')

    Travis::Notifications::Handler::Irc.new.notify('build:finished', build)

    expected = [
      'JOIN #travis',
      'PRIVMSG #travis :[travis-ci] svenfuchs/broken_build#1 (master - 62aae5f : Sven Fuchs): The build failed.',
      'PRIVMSG #travis :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      "PRIVMSG #travis :[travis-ci] Build details : http://travis-ci.org/svenfuchs/broken_build/builds/#{build.id}",
      "PART #travis",
      'JOIN #rails',
      'PRIVMSG #rails :[travis-ci] svenfuchs/broken_build#1 (master - 62aae5f : Sven Fuchs): The build failed.',
      'PRIVMSG #rails :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      "PRIVMSG #rails :[travis-ci] Build details : http://travis-ci.org/svenfuchs/broken_build/builds/#{build.id}",
      "PART #rails",
      "QUIT",
      'JOIN #example',
      'PRIVMSG #example :[travis-ci] svenfuchs/broken_build#1 (master - 62aae5f : Sven Fuchs): The build failed.',
      'PRIVMSG #example :[travis-ci] Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
      "PRIVMSG #example :[travis-ci] Build details : http://travis-ci.org/svenfuchs/broken_build/builds/#{build.id}",
      'PART #example',
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end
end
