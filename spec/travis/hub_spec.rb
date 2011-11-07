require 'spec_helper'

describe Travis::Hub do
  let(:hub)     { Travis::Hub.new }
  let(:payload) { hub.send(:decode, '{ "id": 1 }') }

  describe 'decode' do
    it 'decodes a json payload' do
      payload['id'].should == 1
    end
  end

  describe 'handler_for' do
    events = %w(
      job:config:started
      job:config:finished
      job:test:started
      job:test:log
      job:test:finished
    )

    events.each do |event|
      it "returns a Job handler for #{event.inspect}" do
        hub.send(:handler_for, event, payload).should be_kind_of(Travis::Hub::Job)
      end
    end
  end
end
