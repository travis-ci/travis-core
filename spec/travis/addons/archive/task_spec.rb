require 'spec_helper'

describe Travis::Addons::Archive::Task do
  include Travis::Testing::Stubs

  let(:subject) { described_class }

  before :each do
    Travis.stubs(:run_service)
  end

  def run
    subject.new({ type: 'log', id: 1 }, {}).run
  end

  it 'runs the :archive_log service' do
    Travis.expects(:run_service).with(:archive_log, id: 1)
    run
  end

  describe 'instrument' do
    let(:publisher) { Travis::Notification::Publisher::Memory.new }
    let(:event)     { publisher.events[1] }

    before :each do
      Travis::Notification.publishers.replace([publisher])
      run
    end

    it 'publishes an event' do
      event.should publish_instrumentation_event(
        event: 'travis.addons.archive.task.run:completed',
        message: 'Travis::Addons::Archive::Task#run:completed for #<Log id=1>',
      )
      event[:data].except(:payload).should == {
        object_type: 'Log',
        object_id: 1
      }
      event[:data][:payload].should_not be_nil
    end
  end
end

