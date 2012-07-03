require 'spec_helper'

describe Travis::Notification::Instrument::Task::Email do
  include Travis::Testing::Stubs

  let(:data)      { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:task)      { Travis::Task::Email.new(data, :recipients => %w(svenfuchs@artweb-design.de)) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.first }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.task.email.run:call",
            :uuid => Travis.uuid
    }
    event[:payload].except(:data).should == {
      :msg => 'Travis::Task::Email#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :email => :finished_email,
      :recipients => %w(svenfuchs@artweb-design.de)
    }
    event[:payload][:data].should_not be_nil
  end
end

