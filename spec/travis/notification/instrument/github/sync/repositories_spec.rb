require 'spec_helper'

describe Travis::Notification::Instrument::Github::Sync::Repositories do
  include Support::ActiveRecord

  let(:user)      { Factory(:user, :login => 'sven', :github_oauth_token => '123456') }
  let(:repo)      { { 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true } } }

  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.first }
  let(:sync)      { Travis::Github::Sync::Repositories.new(user) }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    Travis::Github.stubs(:repositories_for).returns([repo])
    sync.run
  end

  it 'publishes a payload' do
    event.should == {
      :msg => %(Travis::Github::Sync::Repositories#run for #<User id=#{user.id} login="sven">),
      :result => [repo],
      :uuid => Travis.uuid
    }
  end
end
