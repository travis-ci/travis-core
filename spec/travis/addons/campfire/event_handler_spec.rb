require 'spec_helper'

describe Travis::Addons::Campfire::EventHandler do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Campfire::EventHandler }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  describe 'subscription' do
    let(:handler) { subject.any_instance }

    before :each do
      Travis::Event.stubs(:subscribers).returns [:campfire]
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
    let(:task)  { Travis::Addons::Campfire::Task }

    before :each do
      build.stubs(:config => { :notifications => { :campfire => 'room' } })
    end

    def notify
      subject.notify(event, build)
    end

    it 'triggers a task if the build is a push request' do
      build.stubs(:pull_request?).returns(false)
      task.expects(:run).with(:campfire, payload, targets: ['room'])
      notify
    end

    it 'does not trigger a task if the build is a pull request' do
      build.stubs(:pull_request?).returns(true)
      task.expects(:run).never
      notify
    end

    it 'triggers a task if rooms are present' do
      build.stubs(:config => { :notifications => { :campfire => 'room' } })
      task.expects(:run).with(:campfire, payload, targets: ['room'])
      notify
    end

    it 'does not trigger a task if no rooms are present' do
      build.stubs(:config => { :notifications => { :campfire => [] } })
      task.expects(:run).never
      notify
    end

    it 'triggers a task if specified by the config' do
      Travis::Event::Config.any_instance.stubs(:send_on_finished_for?).with(:campfire).returns(false)
      task.expects(:run).never
      notify
    end

    it 'does not trigger task if specified by the config' do
      Travis::Event::Config.any_instance.stubs(:send_on_finish?).with(:campfire).returns(true)
      task.expects(:run).with(:campfire, payload, targets: ['room'])
      notify
    end
  end

  describe :targets do
    let(:handler) { subject.new('build:finished', build, {}, payload) }

    it 'returns an array of urls when given a string' do
      rooms = 'travis:apitoken@42'
      build.stubs(:config => { :notifications => { :campfire => rooms } })
      handler.targets.should == [rooms]
    end

    it 'returns an array of urls when given an array' do
      rooms = ['travis:apitoken@42']
      build.stubs(:config => { :notifications => { :campfire => rooms } })
      handler.targets.should == rooms
    end

    it 'returns an array of multiple urls when given a comma separated string' do
      rooms = 'travis:apitoken@42, evome:apitoken@44'
      build.stubs(:config => { :notifications => { :campfire => rooms } })
      handler.targets.should == rooms.split(',').map(&:strip)
    end

    it 'returns an array of values if the build configuration specifies an array of urls within a config hash' do
      rooms = { :rooms => %w(travis:apitoken&42), :on_success => 'change' }
      build.stubs(:config => { :notifications => { :campfire => rooms } })
      handler.targets.should == rooms[:rooms]
    end
  end

  # describe 'instrumentation' do
  #   it 'instruments with notify.campfire.handler.event.travis' do
  #     ActiveSupport::Notifications.stubs(:publish)
  #     ActiveSupport::Notifications.expects(:publish).with do |event, data|
  #       event =~ /travis.event.handler.campfire.notify/ && data[:target].is_a?(Travis::Event::Handler::Campfire)
  #     end
  #     Travis::Event.dispatch('build:finished', build)
  #   end

  #   it 'meters on "travis.event.handler.campfire.notify:completed"' do
  #     Metriks.expects(:timer).with('v1.travis.event.handler.campfire.notify:completed').returns(stub('timer', :update => true))
  #     Travis::Event.dispatch('build:finished', build)
  #   end
  # end
end
