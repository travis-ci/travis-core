require 'spec_helper'
require 'travis/event/config/spec_helper'

describe Travis::Event::Config::Email do
  include Travis::Testing::Stubs

  let(:config) { Travis::Event::Config::Email.new(build) }

  describe :send_on_finish? do
    it_behaves_like 'a build configuration'
  end

  describe :recipients do
    it "equals the recipients specified in the build configuration if any (given as an array)" do
      recipients = %w(recipient-1@email.com recipient-2@email.com)
      build.stubs(:config => { :notifications => { :recipients => recipients } })
      config.recipients.should contain_recipients(recipients)
    end

    it "equals the recipients specified in the build configuration if any (given as a string)" do
      recipients = 'recipient-1@email.com,recipient-2@email.com'
      build.stubs(:config => { :notifications => { :recipients => recipients } })
      config.recipients.should contain_recipients(recipients)
    end
  end
end
