require 'spec_helper'

describe Travis::Notification::Instrument::Services::Github::FindAdmin do
  include Travis::Testing::Stubs

  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }
  let(:service)   { Travis::Services::Github::FindAdmin.new(repository) }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    User.stubs(:with_permissions).with(:repository_id => repository.id, :admin => true).returns [user]
    GH.stubs(:[]).with("repos/#{repository.slug}").returns('permissions' => { 'admin' => true })
    service.run
  end

  it 'publishes a payload' do
    event.should == {
      :message => "travis.services.github.find_admin.run:completed",
      :uuid => Travis.uuid,
      :payload => {
        :result => user,
        :msg => 'Travis::Services::Github::FindAdmin#find for svenfuchs/minimal: svenfuchs'
      }
    }
  end
end

