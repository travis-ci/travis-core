require 'spec_helper'
require 'travis/features'
require 'support/active_record'
require 'support/mocks/irc'
require 'irc_client'

describe Travis::Notifications::Handler::Irc do
  include Support::ActiveRecord

  attr_reader :irc

  before do
    Travis::Features.start
    TCPSocket.any_instance.stubs(:puts => true, :get => true, :eof? => true)
    Travis.config.notifications = [:irc]
    Travis::Features.activate_user(:short_urls, user)
  end

  let(:irc)  { Support::Mocks::Irc.new }
  let(:user) { Factory(:user, :email => 'owner@example.com') }
  let(:repository) { Factory(:repository, :owner_email => 'owner@example.com') }
  let(:common_irc_config) { { 'notifications' => { 'irc' => "irc.freenode.net:1234#travis" } } }

  def run(build)
    data = Travis::Api.data(build, :for => 'notifications', :version => 'v2')
    Travis::Task::Irc.new(build.irc_channels, data).run
  end

  def custom_irc_config(config)
    common_irc_config.merge('notifications' => { 'irc' => config })
  end

  def expect_irc(host, options = {}, count = 1)
    IrcClient.expects(:new).times(count).with(host, 'travis-ci', { :port => nil }.merge(options)).returns(irc)
  end

  it "no irc notifications" do
    build = Factory(:build)
    IrcClient.expects(:new).never
    run(build)
  end

  it "one irc notification" do
    build = Factory(:successful_build, :config => common_irc_config)

    expect_irc('irc.freenode.net', { :port => '1234' })

    expect_change_code = Url.find_or_create_by_url("https://github.com/svenfuchs/minimal/compare/master...develop").code
    expect_build_code = Url.find_or_create_by_url("http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}").code

    run(build)

    expected = [
      'JOIN #travis',
      'PRIVMSG #travis :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      "PRIVMSG #travis :[travis-ci] Change view : http://trvs.io/#{expect_change_code}",
      "PRIVMSG #travis :[travis-ci] Build details : http://trvs.io/#{expect_build_code}",
      'PART #travis',
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end

  it "one irc notification using notice" do
    build = Factory(:successful_build, :config => custom_irc_config({ 'use_notice' => true, 'channels' => ["irc.freenode.net:1234#travis"] }))

    expect_irc('irc.freenode.net', { :port => '1234' })

    expect_change_code = Url.find_or_create_by_url("https://github.com/svenfuchs/minimal/compare/master...develop").code
    expect_build_code = Url.find_or_create_by_url("http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}").code

    run(build)

    expected = [
      'JOIN #travis',
      'NOTICE #travis :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      "NOTICE #travis :[travis-ci] Change view : http://trvs.io/#{expect_change_code}",
      "NOTICE #travis :[travis-ci] Build details : http://trvs.io/#{expect_build_code}",
      'PART #travis',
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end

  it "one irc notification without joining the channel" do
    build = Factory(:successful_build, :config => custom_irc_config({ 'skip_join' => true, 'channels' => ["irc.freenode.net:1234#travis"] }))

    expect_irc('irc.freenode.net', { :port => '1234' })

    expect_change_code = Url.find_or_create_by_url("https://github.com/svenfuchs/minimal/compare/master...develop").code
    expect_build_code = Url.find_or_create_by_url("http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}").code

    run(build)

    expected = [
      'PRIVMSG #travis :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      "PRIVMSG #travis :[travis-ci] Change view : http://trvs.io/#{expect_change_code}",
      "PRIVMSG #travis :[travis-ci] Build details : http://trvs.io/#{expect_build_code}"
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end

  context 'customized template message' do

    let(:simple_template) do
      custom_irc_config({ 'channels' => ["irc.freenode.net:1234#travis"], 'template' => "%{repository} (%{commit}): %{message} %{foo}" })
    end
    let(:multiple_template) do
      custom_irc_config({ 'channels' => ["irc.freenode.net:1234#travis"] , 'template' => ["%{repository} (%{commit}) : %{message} %{foo}", "Build details: %{build_url}"] })
    end

    it "should print a multiple line messages" do
      build = Factory(:successful_build, :config => multiple_template)

      expect_irc('irc.freenode.net', { :port => '1234' })
      expect_code = Url.find_or_create_by_url("http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}").code

      run(build)

      expected = [
        "JOIN #travis",
        "PRIVMSG #travis :[travis-ci] svenfuchs/successful_build (62aae5f) : The build passed. ",
        "PRIVMSG #travis :[travis-ci] Build details: http://trvs.io/#{expect_code}"
      ]
      expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
    end

    it "should print a single line messages" do
      build = Factory(:successful_build, :config => simple_template)

      expect_irc('irc.freenode.net', { :port => '1234' })

      run(build)

      expected = [
        'JOIN #travis',
        'PRIVMSG #travis :[travis-ci] svenfuchs/successful_build (62aae5f): The build passed. ',
      ]
      expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
    end
  end

  it "two irc notifications to different hosts, using config with notification rules" do
    config = custom_irc_config({ 'skip_join' => false, 'on_success' => "always", 'channels' => ["irc.freenode.net:1234#travis", "irc.example.com#example"] })
    build  = Factory(:successful_build, :config => config)

    expect_irc('irc.freenode.net', { :port => '1234' })
    expect_irc('irc.example.com')

    expect_change_code = Url.find_or_create_by_url("https://github.com/svenfuchs/minimal/compare/master...develop").code
    expect_build_code = Url.find_or_create_by_url("http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}").code

    run(build)

    expected = [
      'JOIN #travis',
      'PRIVMSG #travis :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      "PRIVMSG #travis :[travis-ci] Change view : http://trvs.io/#{expect_change_code}",
      "PRIVMSG #travis :[travis-ci] Build details : http://trvs.io/#{expect_build_code}",
      "PART #travis",
      "QUIT",
      'JOIN #example',
      'PRIVMSG #example :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      "PRIVMSG #example :[travis-ci] Change view : http://trvs.io/#{expect_change_code}",
      "PRIVMSG #example :[travis-ci] Build details : http://trvs.io/#{expect_build_code}",
      'PART #example',
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end

  it "two irc notifications to different hosts, using config with notification rules, without joining channel" do
    config = custom_irc_config({ 'skip_join' => true, 'on_success' => "always", 'channels' => ["irc.freenode.net:1234#travis", "irc.example.com#example"] })
    build  = Factory(:successful_build, :config => config)

    expect_irc('irc.freenode.net', { :port => '1234' })
    expect_irc('irc.example.com')

    expect_change_code = Url.find_or_create_by_url("https://github.com/svenfuchs/minimal/compare/master...develop").code
    expect_build_code = Url.find_or_create_by_url("http://travis-ci.org/svenfuchs/successful_build/builds/#{build.id}").code

    run(build)

    expected = [
      'PRIVMSG #travis :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      "PRIVMSG #travis :[travis-ci] Change view : http://trvs.io/#{expect_change_code}",
      "PRIVMSG #travis :[travis-ci] Build details : http://trvs.io/#{expect_build_code}",
      "QUIT",
      'PRIVMSG #example :[travis-ci] svenfuchs/successful_build#1 (master - 62aae5f : Sven Fuchs): The build passed.',
      "PRIVMSG #example :[travis-ci] Change view : http://trvs.io/#{expect_change_code}",
      "PRIVMSG #example :[travis-ci] Build details : http://trvs.io/#{expect_build_code}",
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end

  it "irc notifications to the same host should not disconnect between notifications" do
    build = Factory(:broken_build, :config => custom_irc_config(["irc.freenode.net:6667#travis", "irc.freenode.net:6667#rails", "irc.example.com#example"]))

    expect_irc('irc.freenode.net', { :port => '6667' }, 1) # (Only connect once to irc.freenode.net)
    expect_irc('irc.example.com')

    expect_change_code = Url.find_or_create_by_url("https://github.com/svenfuchs/minimal/compare/master...develop").code
    expect_build_code = Url.find_or_create_by_url("http://travis-ci.org/svenfuchs/broken_build/builds/#{build.id}").code

    run(build)

    expected = [
      'JOIN #travis',
      'PRIVMSG #travis :[travis-ci] svenfuchs/broken_build#1 (master - 62aae5f : Sven Fuchs): The build failed.',
      "PRIVMSG #travis :[travis-ci] Change view : http://trvs.io/#{expect_change_code}",
      "PRIVMSG #travis :[travis-ci] Build details : http://trvs.io/#{expect_build_code}",
      "PART #travis",
      'JOIN #rails',
      'PRIVMSG #rails :[travis-ci] svenfuchs/broken_build#1 (master - 62aae5f : Sven Fuchs): The build failed.',
      "PRIVMSG #rails :[travis-ci] Change view : http://trvs.io/#{expect_change_code}",
      "PRIVMSG #rails :[travis-ci] Build details : http://trvs.io/#{expect_build_code}",
      "PART #rails",
      "QUIT",
      'JOIN #example',
      'PRIVMSG #example :[travis-ci] svenfuchs/broken_build#1 (master - 62aae5f : Sven Fuchs): The build failed.',
      "PRIVMSG #example :[travis-ci] Change view : http://trvs.io/#{expect_change_code}",
      "PRIVMSG #example :[travis-ci] Build details : http://trvs.io/#{expect_build_code}",
      'PART #example',
    ]
    expected.each_with_index { |expected, ix| irc.output[ix].should == expected }
  end
end

