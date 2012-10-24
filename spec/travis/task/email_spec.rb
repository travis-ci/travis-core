require 'spec_helper'

describe Travis::Task::Email do
  include Travis::Testing::Stubs

  let(:email)      { stub('email', deliver: true) }
  let(:mailer)     { Travis::Mailer::Build }
  let(:payload)    { Travis::Api.data(build, for: 'event', version: 'v0') }
  let(:handler)    { Travis::Task::Email.new(payload, recipients: recipients) }

  attr_reader :recipients

  before :each do
    @recipients = ['svenfuchs@artweb-design.de']
    mailer.stubs(:finished_email).returns(email)
    Broadcast.stubs(:by_repo).returns([broadcast])
  end

  it 'creates an email for the build email recipients' do
    mailer.expects(:finished_email).with(payload.deep_symbolize_keys, recipients).returns(email)
    handler.run
  end

  it 'sends the email' do
    email.expects(:deliver)
    handler.run
  end

  it 'includes valid email addresses' do
    @recipients = ['me@email.org']
    handler.recipients.should contain_recipients('me@email.org')
  end

  it 'ignores email addresses (me@email)' do
    @recipients = ['me@email']
    handler.recipients.should_not contain_recipients('me@email')
  end

  it 'ignores email address ending in .local' do
    @recipients = ['me@email.local']
    handler.recipients.should_not contain_recipients('me@email.local')
  end
end
