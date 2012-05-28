require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::Handler::Email do
  include Support::ActiveRecord

  let(:build)   { Factory(:build, :state => 'finished') }
  let(:email)   { stub('email', :deliver => true) }
  let(:mailer)  { Travis::Mailer::Build }
  let(:handler) { Travis::Notifications::Handler::Email.new }
  let(:data)    { Travis::Api.data(build, :for => 'notifications', :version => 'v2') }

  before do
    Travis.config.notifications = [:email]
  end

  def notify!
    handler.notify('build:finished', build)
  end

  it 'build:started does not notify' do
    Travis::Notifications::Handler::Email.any_instance.expects(:notify).never
    Travis::Notifications.dispatch('build:started', build)
  end

  it 'build:finish notifies' do
    Travis::Notifications::Handler::Email.any_instance.expects(:notify)
    Travis::Notifications.dispatch('build:finished', build)
  end

  describe 'notify' do
    before :each do
      mailer.stubs(:finished_email).returns(email)
    end

    it 'creates an email for the build email recipients' do
      mailer.expects(:finished_email).with(data, 'svenfuchs@artweb-design.de').returns(email)
      notify!
    end

    it 'sends the email' do
      email.expects(:deliver)
      notify!
    end
  end
end
