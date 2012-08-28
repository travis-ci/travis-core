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

  describe :include_logs? do
    # TODO default is to be deprecated and changed to false
    it 'returns true by default (single url given)' do
      build.stubs(:config => { :notifications => { :webhooks => 'http://domain.com' } })
      config.include_logs?.should be_true
    end

    it 'returns true by default (array of urls given)' do
      build.stubs(:config => { :notifications => { :webhooks => ['http://domain.com'] } })
      config.include_logs?.should be_true
    end

    it 'returns true by default (hash given)' do
      build.stubs(:config => { :notifications => { :webhooks => {} } })
      config.include_logs?.should be_true
    end

    it 'returns true if defined in the config' do
      build.stubs(:config => { :notifications => { :webhooks => { :include_logs => true } } })
      config.include_logs?.should be_true
    end

    it 'returns false if defined in the config' do
      build.stubs(:config => { :notifications => { :webhooks => { :include_logs => false } } })
      config.include_logs?.should be_false
    end
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

  describe 'does not explode on invalid .travis.yml syntax' do
    it 'when :notifications contains an array' do
      # e.g. https://github.com/sieben/sieben.github.com/blob/05f09da13221e054ef2dafa1baf2fb4d9826ebb3/.travis.yml
      config.config[:notifications] = [{ :email => false }]
      lambda { config.webhooks }.should_not raise_error
    end
  end
end
