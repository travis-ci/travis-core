require 'spec_helper'

describe Travis::Notification::Instrument::Services::Requests::Receive do
  include Support::ActiveRecord

  let(:payload)   { JSON.parse(GITHUB_PAYLOADS['gem-release']) }
  let(:service)   { Travis::Services::Requests::Receive.new(nil, :event_type => 'push', :payload => payload, :token => 'token') }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.last }

  before :each do
    Request.any_instance.stubs(:configure)
    Request.any_instance.stubs(:start)
    Travis::Notification.publishers.replace([publisher])
    service.run
  end

  it 'publishes a payload' do
    event.should == {
      :message => "travis.services.requests.receive.run:completed",
      :uuid => Travis.uuid,
      :payload => {
        :msg => 'Travis::Services::Requests::Receive#run type="push"',
        :type => 'push',
        :token => 'token',
        :accept? => true,
        :payload => payload
      }
    }
  end
end
