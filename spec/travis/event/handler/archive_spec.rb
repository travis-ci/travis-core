require 'spec_helper'

describe Travis::Event::Handler::Archive do
  let(:handler) { Travis::Event::Handler::Archive.any_instance }
  let(:build)   { stub('build') }

  before do
    Travis.config.notifications = [:archive]
  end

  describe 'subscription' do
    it 'build:started does not call' do
      handler.expects(:call).never
      Travis::Event.dispatch('build:started', build)
    end

    it 'build:finish calls' do
      handler.expects(:call)
      Travis::Event.dispatch('build:finished', build)
    end
  end
end
