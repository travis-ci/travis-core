require 'spec_helper'

describe Travis::Notification::Instrument::Services::Requests::Requeue do
  include Support::ActiveRecord

  # let(:payload)   { JSON.parse(GITHUB_PAYLOADS['gem-release']) }
  # let(:service)   { Travis::Services::Requests::Rqueue.new(nil, build_id: 'push', payload: payload, token: 'token') }
  # let(:publisher) { Travis::Notification::Publisher::Memory.new }
  # let(:event)     { publisher.events.last }

  # before :each do
  #   Travis::Notification.publishers.replace([publisher])
  #   service.run
  # end

  # it 'publishes a event' do
  #   event.should publish_instrumentation_event(
  #     event: 'travis.services.requests.requeue.run:completed',
  #     message: 'Travis::Services::Requests::Requeue#run type="push"',
  #     data: {
  #       type: 'push',
  #       token: 'token',
  #       accept?: true,
  #       payload: payload
  #     }
  #   )
  # end
end
