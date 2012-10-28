require 'spec_helper'

describe Travis::Addons::Hipchat::EventHandler do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Hipchat::EventHandler }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  describe 'subscription' do
    let(:handler) { subject.any_instance }

    before :each do
      Travis::Event.stubs(:subscribers).returns [:hipchat]
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
    let(:task)  { Travis::Addons::Hipchat::Task }

    before :each do
      build.stubs(:config => { :notifications => { :hipchat => 'room' } })
    end

    def notify
      subject.notify(event, build)
    end

    it 'triggers a task if the build is a push request' do
      build.stubs(:pull_request?).returns(false)
      task.expects(:run).with(:hipchat, payload, targets: ['room'])
      notify
    end

    it 'does not trigger a task if the build is a pull request' do
      build.stubs(:pull_request?).returns(true)
      task.expects(:run).never
      notify
    end

    it 'triggers a task if rooms are present' do
      build.stubs(:config => { :notifications => { :hipchat => 'room' } })
      task.expects(:run).with(:hipchat, payload, targets: ['room'])
      notify
    end

    it 'does not trigger a task if no rooms are present' do
      build.stubs(:config => { :notifications => { :hipchat => [] } })
      task.expects(:run).never
      notify
    end

    it 'triggers a task if specified by the config' do
      Travis::Event::Config.any_instance.stubs(:send_on_finished_for?).with(:hipchat).returns(false)
      task.expects(:run).never
      notify
    end

    it 'does not trigger task if specified by the config' do
      Travis::Event::Config.any_instance.stubs(:send_on_finish?).with(:hipchat).returns(true)
      task.expects(:run).with(:hipchat, payload, targets: ['room'])
      notify
    end
  end

  describe :targets do
    let(:handler) { subject.new('build:finished', build, {}, payload) }

    it 'returns an array of urls when given a string' do
      rooms = 'd41d8cd98f00b204e9800998ecf8427e'
      build.stubs(:config => { :notifications => { :hipchat => rooms } })
      handler.targets.should == [rooms]
    end

    it 'returns an array of urls when given an array' do
      rooms = ['d41d8cd98f00b204e9800998ecf8427e']
      build.stubs(:config => { :notifications => { :hipchat => rooms } })
      handler.targets.should == rooms
    end

    it 'returns an array of multiple urls when given a comma separated string' do
      rooms = 'd41d8cd98f00b204e9800998ecf8427e,322fdcced7226b1d66396c68efedb0c1'
      build.stubs(:config => { :notifications => { :hipchat => rooms } })
      handler.targets.should == rooms.split(',').map(&:strip)
    end

    it 'returns an array of values if the build configuration specifies an array of urls within a config hash' do
      rooms = { :rooms => %w(322fdcced7226b1d66396c68efedb0c1), :on_success => 'change' }
      build.stubs(:config => { :notifications => { :hipchat => rooms } })
      handler.targets.should == rooms[:rooms]
    end
  end

  # describe 'instrumentation' do
  #   it 'instruments with notify.hipchat.handler.event.travis' do
  #     ActiveSupport::Notifications.stubs(:publish)
  #     ActiveSupport::Notifications.expects(:publish).with do |event, data|
  #       event =~ /travis.event.handler.hipchat.notify/ && data[:target].is_a?(Travis::Event::Handler::Hipchat)
  #     end
  #     Travis::Event.dispatch('build:finished', build)
  #   end

  #   it 'meters on "travis.event.handler.hipchat.notify:completed"' do
  #     Metriks.expects(:timer).with('v1.travis.event.handler.hipchat.notify:completed').returns(stub('timer', :update => true))
  #     Travis::Event.dispatch('build:finished', build)
  #   end
  # end
end
