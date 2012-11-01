require 'spec_helper'

describe Travis::Notification::Instrument::Services::Github::FetchConfig do
  include Travis::Testing::Stubs

  let(:body)      { { 'content' => ['foo: Foo'].pack('m') } }
  let(:service)   { Travis::Services::Github::FetchConfig.new(nil, request: request) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    GH.stubs(:[]).returns(body)
    Travis::Notification.publishers.replace([publisher])
  end

  it 'publishes a payload' do
    service.run
    event.should == {
      :message => "travis.services.github.fetch_config.run:completed",
      :uuid => Travis.uuid,
      :payload => {
        :result => { 'foo' => 'Foo', '.result' => 'configured' },
        :msg => 'Travis::Services::Github::FetchConfig#run https://api.github.com/repos/svenfuchs/minimal/contents/.travis.yml?ref=62aae5f70ceee39123ef',
        :url => 'https://api.github.com/repos/svenfuchs/minimal/contents/.travis.yml?ref=62aae5f70ceee39123ef'
      }
    }
  end

  it 'strips an access_token if present (1)' do
    service.stubs(:config_url).returns('/foo/bar?access_token=123456')
    service.run
    event[:payload][:url].should == '/foo/bar?access_token=[secure]'
  end

  it 'strips an access_token if present (2)' do
    service.stubs(:config_url).returns('/foo/bar?ref=abcd&access_token=123456')
    service.run
    event[:payload][:url].should == '/foo/bar?ref=abcd&access_token=[secure]'
  end
end
