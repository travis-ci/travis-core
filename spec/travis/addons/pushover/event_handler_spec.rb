require 'spec_helper'

describe Travis::Addons::Pushover::EventHandler do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Pushover::EventHandler }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  describe 'subscription' do
    let(:handler) { subject.any_instance }

    before :each do
      Travis::Event.stubs(:subscribers).returns [:pushover]
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
    let(:task)  { Travis::Addons::Pushover::Task }

    before :each do
      build.stubs(:config => { :notifications => { :pushover => { :users => ['userone', 'usertwo'], :api_key => 'myapikey' } } })
    end

    def notify
      subject.notify(event, build)
    end

    it 'passes ssl key from repository to config' do
      config = stub('config', :notification_values => {})

      Travis::Event::Config.expects(:new).with(payload, build.repository.key).
        returns(config)
      notify
    end

    it 'triggers a task if the build is a push request' do
      build.stubs(:pull_request?).returns(false)
      task.expects(:run).with(:pushover, payload, users: ['userone', 'usertwo'], api_key: 'myapikey')
      notify
    end

    it 'does not trigger a task if the build is a pull request' do
      build.stubs(:pull_request?).returns(true)
      task.expects(:run).never
      notify
    end

    it 'triggers a task if users and api_key are present' do
      build.stubs(:config => { :notifications => { :pushover => { users: ['userone', 'usertwo'], api_key: 'myapikey' } } })
      task.expects(:run).with(:pushover, payload, users: ['userone', 'usertwo'], api_key: 'myapikey')
      notify
    end

    it 'does not trigger a task if no users are present' do
      build.stubs(:config => { :notifications => { :pushover => { users: [], api_key: 'myapikey' } } })
      task.expects(:run).never
      notify
    end

    it 'does not trigger a task if no api_key is present' do
      build.stubs(:config => { :notifications => { :pushover => { users: ['userone', 'usertwo'] } } })
      task.expects(:run).never
      notify
    end

    it 'triggers a task if specified by the config' do
      Travis::Event::Config.any_instance.stubs(:send_on_finished_for?).with(:pushover).returns(true)
      task.expects(:run).with(:pushover, payload, users: ['userone', 'usertwo'], api_key: 'myapikey')
      notify
    end

    it 'does not trigger task if specified by the config' do
      Travis::Event::Config.any_instance.stubs(:send_on_finished_for?).with(:pushover).returns(false)
      task.expects(:run).never
      notify
    end
  end

  describe :users do
    let(:handler) { subject.new('build:finished', build, {}, payload) }

    it 'returns an array of user keys when given a string' do
      users = 'only_one_user'
      build.stubs(:config => { :notifications => { :pushover => users } })
      handler.users.should == ['only_one_user']
    end

    it 'returns an array of user keys when given an array' do
      users = ['only_one_user']
      build.stubs(:config => { :notifications => { :pushover => users } })
      handler.users.should == users
    end

    it 'returns an array of multiple user keys when given a comma separated string' do
      users = 'userkeyA, userkeyB'
      build.stubs(:config => { :notifications => { :pushover => users } })
      handler.users.should == users.split(',').map(&:strip)
    end

    it 'returns an array of values if the build configuration specifies an array of user keys within a config hash' do
      build.stubs(:config => { :notifications => { :pushover => { users: ['userkeyA', 'userkeyB'], on_success: 'change' } } })
      handler.users.should == ['userkeyA', 'userkeyB']
    end
  end

end
