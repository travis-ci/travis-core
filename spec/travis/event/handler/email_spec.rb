require 'spec_helper'

describe Travis::Event::Handler::Email do
  include Travis::Testing::Stubs

  before :each do
    build.stubs(:previous_result).returns(nil)
    Broadcast.stubs(:by_repo).returns([broadcast])
  end

  describe 'subscription' do
    let(:handler) { Travis::Event::Handler::Email.any_instance }

    before do
      Travis::Event.stubs(:subscribers).returns [:email]
      handler.stubs(:handle => true, :handle? => true)
    end

    it 'build:started does not notify' do
      handler.expects(:notify).never
      Travis::Event.dispatch('build:started', build)
    end

    it 'build:finish notifies' do
      handler.expects(:notify)
      Travis::Event.dispatch('build:finished', build)
    end
  end

  describe 'recipients' do
    let(:handler) { Travis::Event::Handler::Email.new('build:finished', build) }

    it 'includes valid email addresses' do
      email = 'me@email.org'
      build.config[:notifications] = { :email => [email] }
      handler.recipients.should contain_recipients(email)
    end

    it 'ignores email addresses (me@email)' do
      email = 'me@email'
      build.config[:notifications] = { :email => [email] }
      handler.recipients.should_not contain_recipients(email)
    end

    it "ignores email address ending in .local" do
      email = 'me@email.local'
      build.config[:notifications] = { :email => [email] }
      handler.recipients.should_not contain_recipients(email)
    end

    it 'contains the author emails if the build has them set' do
      build.commit.stubs(:author_email => 'author-1@email.com,author-2@email.com')
      handler.recipients.should contain_recipients(build.commit.author_email)
    end

    it 'contains the committer emails if the build has them set' do
      build.commit.stubs(:committer_email => 'committer-1@email.com,committer-2@email.com')
      handler.recipients.should contain_recipients(build.commit.committer_email)
    end

    it "contains the build's repository owner_email if it has one" do
      build.repository.stubs(:owner_email => 'owner-1@email.com,owner-2@email.com')
      handler.recipients.should contain_recipients(build.commit.committer_email)
    end

    it "contains the build's repository owner_email if it has a configuration but no emails specified" do
      build.stubs(:config => {})
      build.repository.stubs(:owner_email => 'owner-1@email.com')
      handler.recipients.should contain_recipients(repository.owner_email)
    end
  end

  # describe 'instrumentation' do
  #   it 'instruments with "travis.event.handler.email.notify"' do
  #     ActiveSupport::Notifications.stubs(:publish)
  #     ActiveSupport::Notifications.expects(:publish).with do |event, data|
  #       event =~ /travis.event.handler.email.notify/ && data[:target].is_a?(Travis::Event::Handler::Email)
  #     end
  #     Travis::Event.dispatch('build:finished', build)
  #   end

  #   it 'meters on "travis.event.handler.email.notify:completed"' do
  #     Metriks.expects(:timer).with('v1.travis.event.handler.email.notify:completed').returns(stub('timer', :update => true))
  #     Travis::Event.dispatch('build:finished', build)
  #   end
  # end
end
