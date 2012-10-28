require 'spec_helper'

describe Travis::Notification::Instrument::Services::Github::SyncUser::Organizations do
  include Support::ActiveRecord

  let(:service)   { Travis::Services::Github::SyncUser::Organizations.new(user) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:events)    { publisher.events }

  let(:travis)    { Organization.find_by_login('travis-ci') }
  let(:sinatra)   { Organization.find_by_login('sinatra') }

  let(:user)      { Factory(:user, :login => 'sven', :github_oauth_token => '123456') }
  let(:data)      { [ { 'id' => 1, 'name' => 'Travis CI', 'login' => 'travis-ci' }, { 'id' => 2, 'name' => 'Sinatra', 'login' => 'sinatra' } ] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    GH.stubs(:[]).with('user/orgs').returns data
    service.run
  end

  it 'publishes a payload on :run' do
    events[3].should == {
      :message => "travis.services.github.sync_user.organizations.run:completed",
      :payload => {
        :msg => %(Travis::Services::Github::SyncUser::Organizations#run for #<User id=#{user.id} login="sven">),
        :result => {
          :synced => [{ :id => travis.id, :login => 'travis-ci' }, { :id => sinatra.id, :login => 'sinatra' }],
          :removed => []
        }
      },
      :uuid => Travis.uuid
    }
  end

  it 'publishes a payload on :fetch' do
    events[2].should == {
      :message => "travis.services.github.sync_user.organizations.fetch:completed",
      :payload => {
        :msg => %(Travis::Services::Github::SyncUser::Organizations#fetch for #<User id=#{user.id} login="sven">),
        :result => data
      },
      :uuid => Travis.uuid
    }
  end
end

