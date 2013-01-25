require 'spec_helper'

describe Travis::Addons::Archive::EventHandler do
  include Travis::Testing::Stubs

  let(:subject) { described_class }

  before :each do
    Travis::Addons::Archive::Task.stubs(:run)
    Travis::Features.stubs(:feature_active?).with(:log_archiving).returns(true)
  end

  describe 'subscription' do
    let(:handler) { subject.any_instance }

    before :each do
      Travis::Event.stubs(:subscribers).returns [:archive]
      Travis::Api.stubs(:data).returns(stub('data'))
    end

    it 'build:started does not notify' do
      handler.expects(:notify).never
      Travis::Event.dispatch('build:started', build)
    end

    it 'log:aggregated notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('log:aggregated', build)
    end
  end

  describe 'handler' do
    let(:task) { Travis::Addons::Archive::Task }

    it 'runs the archive task' do
      task.expects(:run).with(:archive, type: 'log', id: log.id, job_id: log.job_id)
      subject.notify('log:aggregated', log)
    end
  end

  describe 'instrument' do
    let(:publisher) { Travis::Notification::Publisher::Memory.new }
    let(:event)     { publisher.events[1] }

    before :each do
      Travis::Notification.publishers.replace([publisher])
      subject.notify('log:aggregated', log)
    end

    it 'publishes an event' do
      event.should publish_instrumentation_event(
        event: 'travis.addons.archive.event_handler.notify:completed',
        message: 'Travis::Addons::Archive::EventHandler#notify:completed (log:aggregated) for #<Log id=1>',
      )
      event[:data].except(:payload).should == {
        event: 'log:aggregated',
        object_type: 'Log',
        object_id: 1
      }
      event[:data][:payload].should_not be_nil
    end
  end
end
