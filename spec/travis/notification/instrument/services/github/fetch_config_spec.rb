require 'spec_helper'

describe Travis::Notification::Instrument::Services::Github::FetchConfig do
  include Travis::Testing::Stubs

  let(:body)      { { 'content' => ['foo: Foo'].pack('m') } }
  let(:service)   { Travis::Services::Github::FetchConfig.new(request) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    GH.stubs(:[]).returns(body)
    Travis::Notification.publishers.replace([publisher])
    service.run
  end

  it 'publishes a payload' do
    event.should == {
      :message => "travis.services.github.fetch_config.run:completed",
      :uuid => Travis.uuid,
      :payload => {
        :result => { 'foo' => 'Foo', '.result' => 'configured' },
        :msg => 'Travis::Services::Github::FetchConfig#fetch https://api.github.com/repos/svenfuchs/minimal/contents/.travis.yml?ref=62aae5f70ceee39123ef',
        :url => 'https://api.github.com/repos/svenfuchs/minimal/contents/.travis.yml?ref=62aae5f70ceee39123ef'
      }
    }
  end
end
