require 'spec_helper'

describe Travis::Notification::Instrument::Services::Github::SyncUser::Repositories do
  include Support::ActiveRecord

  let(:service)   { Travis::Services::Github::SyncUser::Repositories.new(user) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:events)    { publisher.events }

  let(:user)      { Factory(:user, :login => 'sven', :github_oauth_token => '123456') }
  let(:data)      { [{ 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true }, 'private' => false }] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    GH.stubs(:[]).returns(data)
    service.run
  end

  it 'publishes a payload on :run' do
    events[3].should == {
      :message => "travis.services.github.sync_user.repositories.run:completed",
      :payload => {
        :msg => %(Travis::Services::Github::SyncUser::Repositories#run for #<User id=#{user.id} login="sven">),
        :resources => ['user/repos'],
        :result => {
          :synced => [{ :id => Repository.last.id, :owner => 'sven', :name => 'minimal' }],
          :removed => []
        }
      },
      :uuid => Travis.uuid
    }
  end

  it 'publishes a payload on :fetch' do
    events[2].should == {
      :message => "travis.services.github.sync_user.repositories.fetch:completed",
      :payload => {
        :msg => %(Travis::Services::Github::SyncUser::Repositories#fetch for #<User id=#{user.id} login="sven">),
        :resources => ['user/repos'],
        :result => data
      },
      :uuid => Travis.uuid
    }
  end
end
