require 'spec_helper'

describe Travis::Notification::Instrument::Github::Repositories do
  include Travis::Testing::Stubs

  let(:repos)     { Travis::Github::Repositories.new(user) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.first }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    GH.stubs(:[]).returns([])
    repos.fetch
  end

  it 'publishes a payload' do
    event.should == {
      :msg => 'Travis::Github::Repositories#fetch for #<User id=1 login="svenfuchs">',
      :result => [],
      :uuid => Travis.uuid
    }
  end
end

