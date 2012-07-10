require 'spec_helper'

describe Travis::Notification::Instrument::Github::Repositories do
  include Travis::Testing::Stubs

  let(:repos)     { Travis::Github::Repositories.new(user) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }
  let(:data)      { [ { 'name' => 'public', 'private' => false }, { 'name' => 'private', 'private' => true } ] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    GH.stubs(:[]).returns(data)
    repos.fetch
  end

  it 'publishes a payload' do
    event.should == {
      :message => "travis.github.repositories.fetch:completed",
      :payload => {
        :msg => "Travis::Github::Repositories#fetch for #<User id=1 login=\"svenfuchs\">",
        :resources => ['user/repos'],
        :data => data,
        :result => [data.first]
      },
      :uuid => Travis.uuid
    }
  end
end

