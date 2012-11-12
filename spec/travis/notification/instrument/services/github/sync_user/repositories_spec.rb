require 'spec_helper'

describe Travis::Notification::Instrument::Services::Github::SyncUser::Repositories do
  include Support::ActiveRecord

  let(:service)   { Travis::Services::Github::SyncUser::Repositories.new(user) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:events)    { publisher.events }

  let(:user)      { Factory(:user, login: 'sven', github_oauth_token: '123456') }
  let(:data)      { [{ 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true }, 'private' => false }] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    GH.stubs(:[]).returns(data)
    service.run
  end

  it 'publishes a event on :run' do
    events[3].should publish_instrumentation_event(
      event: 'travis.services.github.sync_user.repositories.run:completed',
      message: %(Travis::Services::Github::SyncUser::Repositories#run for #<User id=#{user.id} login="sven">),
      result: {
        synced: [{ id: Repository.last.id, owner: 'sven', name: 'minimal' }],
        removed: []
      },
      data: {
        resources: ['user/repos'],
      }
    )
  end

  it 'publishes a event on :fetch' do
    events[2].should publish_instrumentation_event(
      event: 'travis.services.github.sync_user.repositories.fetch:completed',
      message: %(Travis::Services::Github::SyncUser::Repositories#fetch for #<User id=#{user.id} login="sven">),
      result: data,
      data: {
        resources: ['user/repos'],
      }
    )
  end
end
