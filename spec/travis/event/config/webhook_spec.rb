require 'spec_helper'
require 'travis/event/config/spec_helper'

describe Travis::Event::Config::Webhook do
  include Travis::Testing::Stubs

  let(:config) { Travis::Event::Config::Webhook.new(build) }

  describe :send_on_finish? do
    before :each do
      build.stubs(:config => { :notifications => { :webhooks => 'http://example.com' } })
    end

    it_behaves_like 'a build configuration'
  end

  describe :webhooks do
    it 'returns an array of urls when given a string' do
      webhooks = 'http://evome.fr/notifications'
      build.stubs(:config => { :notifications => { :webhooks => webhooks } })
      config.webhooks.should == [webhooks]
    end

    it 'returns an array of urls when given an array' do
      webhooks = ['http://evome.fr/notifications']
      build.stubs(:config => { :notifications => { :webhooks => webhooks } })
      config.webhooks.should == webhooks
    end

    it 'returns an array of multiple urls when given a comma separated string' do
      webhooks = 'http://evome.fr/notifications, http://example.com'
      build.stubs(:config => { :notifications => { :webhooks => webhooks } })
      config.webhooks.should == webhooks.split(' ').map(&:strip)
    end

    it 'returns an array of urls if the build configuration specifies an array of urls' do
      webhooks = %w(http://evome.fr/notifications http://example.com)
      build.stubs(:config => { :notifications => { :webhooks => webhooks } })
      config.webhooks.should == webhooks
    end

    it 'returns an array of values if the build configuration specifies an array of urls within a config hash' do
      webhooks = { :urls => %w(http://evome.fr/notifications http://example.com), :on_success => 'change' }
      build.stubs(:config => { :notifications => { :webhooks => webhooks } })
      config.webhooks.should == webhooks[:urls]
    end
  end
end
