require 'spec_helper'
require 'support/active_record'

describe Travis::Task::Email do
  include Support::ActiveRecord

  let(:email)      { stub('email', :deliver => true) }
  let(:mailer)     { Travis::Mailer::Build }
  let(:build)      { Factory(:build, :state => 'finished') }
  let(:data)       { Travis::Api.data(build, :for => 'notifications', :version => 'v2') }
  let(:recipients) { ['svenfuchs@artweb-design.de'] }

  def run
    Travis::Task::Email.new(recipients, data).run
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
