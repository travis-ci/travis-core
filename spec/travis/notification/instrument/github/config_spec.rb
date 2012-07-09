require 'spec_helper'

describe Travis::Notification::Instrument::Github::Config do
  include Travis::Testing::Stubs

  let(:url)       { 'https://raw.github.com/svenfuchs/minimal/62aae5f70ceee39123ef/.travis.yml' }
  let(:config)    { Travis::Github::Config.new(url) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }
  let(:response)  { stub('response', :success? => true, :body => 'foo: Foo') }
  let(:http)      { stub('http', :get => response) }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    config.stubs(:http).returns(http)
    config.fetch
  end

  it 'publishes a payload' do
    event.should == {
      :message => "travis.github.config.fetch:completed",
      :uuid => Travis.uuid,
      :payload => {
        :result => { 'foo' => 'Foo', '.result' => 'configured' },
        :msg => 'Travis::Github::Config#fetch https://raw.github.com/svenfuchs/minimal/62aae5f70ceee39123ef/.travis.yml',
        :url => 'https://raw.github.com/svenfuchs/minimal/62aae5f70ceee39123ef/.travis.yml'
      }
    }
  end
end

