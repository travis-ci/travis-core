require 'spec_helper'
require 'travis/event/config/spec_helper'

describe Travis::Event::Config::Email do
  include Travis::Testing::Stubs

  let(:config) { Travis::Event::Config::Email.new(build) }

  describe :send_on_finish? do
    it_behaves_like 'a build configuration'
  end

  describe :recipients do
    it 'contains the author emails if the build has them set' do
      build.commit.stub(:author_email => 'author-1@email.com,author-2@email.com')
      config.recipients.should contain_recipients(build.commit.author_email)
    end

    it 'contains the committer emails if the build has them set' do
      build.commit.stub(:committer_email => 'committer-1@email.com,committer-2@email.com')
      config.recipients.should contain_recipients(build.commit.committer_email)
    end

    it "contains the build's repository owner_email if it has one" do
      build.repository.stub(:owner_email => 'owner-1@email.com,owner-2@email.com')
      config.recipients.should contain_recipients(build.commit.committer_email)
    end

    it "contains the build's repository owner_email if it has a configuration but no emails specified" do
      build.stubs(:config => {})
      build.repository.stub(:owner_email => 'owner-1@email.com')
      config.recipients.should contain_recipients(repository.owner_email)
    end

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
