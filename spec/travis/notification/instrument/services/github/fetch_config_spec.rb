require 'spec_helper'

describe Travis::Notification::Instrument::Services::Github::FetchConfig do
  include Travis::Testing::Stubs

  let(:url)       { 'https://raw.github.com/svenfuchs/minimal/62aae5f70ceee39123ef/.travis.yml' }
  let(:service)   { Travis::Services::Github::FetchConfig.new(url) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }
  let(:response)  { stub('response', :success? => true, :body => 'foo: Foo') }
  let(:http)      { stub('http', :get => response) }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    service.stubs(:http).returns(http)
    service.run
  end

  it 'publishes a payload' do
    event.should == {
      :message => "travis.services.github.fetch_config.run:completed",
      :uuid => Travis.uuid,
      :payload => {
        :result => { 'foo' => 'Foo', '.result' => 'configured' },
        :msg => 'Travis::Services::Github::FetchConfig#fetch https://raw.github.com/svenfuchs/minimal/62aae5f70ceee39123ef/.travis.yml',
        :url => 'https://raw.github.com/svenfuchs/minimal/62aae5f70ceee39123ef/.travis.yml'
      }
    }
  end
end
