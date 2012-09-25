require 'spec_helper'

describe Travis::Notification::Instrument::Github::Admin do
  include Travis::Testing::Stubs

  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }
  let(:admin)     { Travis::Github::Admin.new(repository) }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    User.stubs(:with_permissions).with(:repository_id => repository.id, :admin => true).returns [user]
    GH.stubs(:[]).with("repos/#{repository.slug}").returns('permissions' => { 'admin' => true })
    admin.find
  end

  it 'publishes a payload' do
    event.should == {
      :message => "travis.github.admin.find:completed",
      :uuid => Travis.uuid,
      :payload => {
        :result => user,
        :msg => 'Travis::Github::Admin#find for svenfuchs/minimal: svenfuchs'
      }
    }
  end
end

