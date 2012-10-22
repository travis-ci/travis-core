require 'spec_helper'

describe Travis::Task::Email do
  include Travis::Testing::Stubs

  let(:email)      { stub('email', :deliver => true) }
  let(:mailer)     { Travis::Mailer::Build }
  let(:data)       { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:recipients) { ['svenfuchs@artweb-design.de'] }

  before :each do
    Travis::Features.start
    Broadcast.stubs(:by_repo).returns([broadcast])
  end

  def run
    Travis::Task::Email.new(data, :recipients => recipients).run
  end

  describe 'run' do
    before :each do
      mailer.stubs(:finished_email).returns(email)
    end

    it 'creates an email for the build email recipients' do
      mailer.expects(:finished_email).with(data, recipients).returns(email)
      run
    end

    it 'sends the email' do
      email.expects(:deliver)
      run
    end
  end
end
