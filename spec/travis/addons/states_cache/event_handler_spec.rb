require 'spec_helper'

describe Travis::Addons::StatesCache::EventHandler do
  include Travis::Testing::Stubs

  let(:build)   { stub_build(state: :failed, repository: repository) }
  let(:subject) { Travis::Addons::StatesCache::EventHandler }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  describe 'handler' do
    let(:handler) { subject.any_instance }

    before :each do
      Travis::Event.stubs(:subscribers).returns [:states_cache]
      handler.stubs(handle?: true)
    end

    it 'build:finished updates the cache' do
      cache = stub(:cache)
      cache.expects(:write).with(build.repository.id, 'master', { 'id' => 1, 'state' => 'failed' })
      handler.stubs(cache: cache)
      Travis::Event.dispatch('build:finished', build)
    end
  end
end
