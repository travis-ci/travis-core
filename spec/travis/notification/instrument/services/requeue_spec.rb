require 'spec_helper'

describe Travis::Notification::Instrument::Services::Requests::Requeue do
  include Support::ActiveRecord

  # let(:payload)   { JSON.parse(GITHUB_PAYLOADS['gem-release']) }
  # let(:service)   { Travis::Services::Requests::Rqueue.new(nil, :build_id => 'push', :payload => payload, :token => 'token') }
  # let(:publisher) { Travis::Notification::Publisher::Memory.new }
  # let(:event)     { publisher.events.last }

  # before :each do
  #   Travis::Notification.publishers.replace([publisher])
  #   service.run
  # end

  # it 'publishes a payload' do
  #   event.should == {
  #     :message => "travis.services.requests.requeue.run:completed",
  #     :uuid => Travis.uuid,
  #     :payload => {
  #       :msg => 'Travis::Services::Requests::Requeue#run type="push"',
  #       :type => 'push',
  #       :token => 'token',
  #       :accept? => true,
  #       :payload => payload
  #     }
  #   }
  # end
end
