require 'spec_helper'

describe Travis::Notification::Instrument::Github::Sync::Organizations do
  include Support::ActiveRecord

  let(:user)      { Factory(:user, :login => 'sven', :github_oauth_token => '123456') }
  let(:data)      { [ { 'id' => 1, 'name' => 'Travis CI', 'login' => 'travis-ci' }, { 'id' => 2, 'name' => 'Sinatra', 'login' => 'sinatra' } ] }

  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:events)    { publisher.events }
  let(:sync)      { Travis::Github::Sync::Organizations.new(user) }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    GH.stubs(:[]).with('user/orgs').returns data
    sync.run
  end

  it 'publishes a payload on :run' do
    events[3].should == {
      :message => "travis.github.sync.organizations.run:completed",
      :payload => {
        :msg => %(Travis::Github::Sync::Organizations#run for #<User id=#{user.id} login="sven">),
        :result => [{ :id => Organization.find_by_login('travis-ci').id, :login => 'travis-ci' }, { :id => Organization.find_by_login('sinatra').id, :login => 'sinatra' }]
      },
      :uuid => Travis.uuid
    }
  end

  it 'publishes a payload on :fetch' do
    events[2].should == {
      :message => "travis.github.sync.organizations.fetch:completed",
      :payload => {
        :msg => %(Travis::Github::Sync::Organizations#fetch for #<User id=#{user.id} login="sven">),
        :result => data
      },
      :uuid => Travis.uuid
    }
  end
end

