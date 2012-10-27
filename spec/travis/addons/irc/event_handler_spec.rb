require 'spec_helper'

describe Travis::Addons::Irc::EventHandler do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Irc::EventHandler }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  describe 'subscription' do
    let(:handler) { subject.any_instance }

    before :each do
      Travis::Event.stubs(:subscribers).returns [:irc]
      handler.stubs(:handle => true, :handle? => true)
      Travis::Api.stubs(:data).returns(stub('data'))
    end

    it 'build:started does not notify' do
      handler.expects(:notify).never
      Travis::Event.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:finished', build)
    end
  end

  describe 'handler' do
    let(:event) { 'build:finished' }

    before :each do
      build.stubs(:config => { :notifications => { :irc => 'irc.freenode.net#travis' } })
    end

    def notify
      subject.notify(event, build)
    end

    it 'triggers a task if the build is a push request' do
      build.stubs(:pull_request?).returns(false)
      Travis::Task.expects(:run).with(:irc, payload, channels: ['irc.freenode.net#travis'])
      notify
    end

    it 'does not trigger a task if the build is a pull request' do
      build.stubs(:pull_request?).returns(true)
      Travis::Task.expects(:run).never
      notify
    end

    it 'triggers a task if channels are present' do
      build.stubs(:config => { :notifications => { :irc => 'irc.freenode.net#travis' } })
      Travis::Task.expects(:run).with(:irc, payload, channels: ['irc.freenode.net#travis'])
      notify
    end

    it 'does not trigger a task if no channels are present' do
      build.stubs(:config => { :notifications => { :irc => [] } })
      Travis::Task.expects(:run).never
      notify
    end

    it 'triggers a task if specified by the config' do
      Travis::Event::Config.any_instance.stubs(:send_on_finished_for?).with(:irc).returns(false)
      Travis::Task.expects(:run).never
      notify
    end

    it 'does not trigger task if specified by the config' do
      Travis::Event::Config.any_instance.stubs(:send_on_finish?).with(:irc).returns(true)
      Travis::Task.expects(:run).with(:irc, payload, channels: ['irc.freenode.net#travis'])
      notify
    end
  end

  describe :channels do
    let(:handler) { subject.new('build:finished', build, {}, payload) }

    it 'returns an array of urls when given a string' do
      channels = 'irc.freenode.net#travis, irc.freenode.net#rails'
      build.stubs(:config => { :notifications => { :irc => channels } })
      handler.channels.should == ['irc.freenode.net#travis', 'irc.freenode.net#rails']
    end

    it 'returns an array of urls when given an array' do
      channels = ['irc.freenode.net#travis', 'irc.freenode.net#rails']
      build.stubs(:config => { :notifications => { :irc => channels } })
      handler.channels.should == ['irc.freenode.net#travis', 'irc.freenode.net#rails']
    end

    it 'returns an array of urls when given a string on the channels key' do
      channels = 'irc.freenode.net#travis, irc.freenode.net#rails'
      build.stubs(:config => { :notifications => { :irc => { :channels => channels } } })
      handler.channels.should == ['irc.freenode.net#travis', 'irc.freenode.net#rails']
    end

    it 'returns an array of urls when given an array on the channels key' do
      channels = ['irc.freenode.net#travis', 'irc.freenode.net#rails']
      build.stubs(:config => { :notifications => { :irc => { :channels => channels } } })
      handler.channels.should == ['irc.freenode.net#travis', 'irc.freenode.net#rails']
    end
  end

  # describe 'instrumentation' do
  #   it 'instruments with "travis.event.handler.irc.notify"' do
  #     ActiveSupport::Notifications.stubs(:publish)
  #     ActiveSupport::Notifications.expects(:publish).with do |event, data|
  #       event =~ /travis.event.handler.irc.notify/ && data[:target].is_a?(Travis::Event::Handler::Irc)
  #     end
  #     Travis::Event.dispatch('build:finished', build)
  #   end

  #   it 'meters on "travis.event.handler.irc.notify:completed"' do
  #     Metriks.expects(:timer).with('v1.travis.event.handler.irc.notify:completed').returns(stub('timer', :update => true))
  #     Travis::Event.dispatch('build:finished', build)
  #   end
  # end
end
