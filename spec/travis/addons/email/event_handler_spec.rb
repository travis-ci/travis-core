require 'spec_helper'

describe Travis::Addons::Email::EventHandler do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Email::EventHandler }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  describe 'subscription' do
    let(:handler) { subject.any_instance }

    before :each do
      Travis::Event.stubs(:subscribers).returns [:email]
      handler.stubs(handle: true, handle?: true)
      Travis::Api.stubs(:data).returns(stub('data'))
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

  describe 'handler' do
    let(:event)  { 'build:finished' }
    let(:task)   { Travis::Addons::Email::Task }
    let(:params) { { recipients: ['svenfuchs@artweb-design.de'], broadcasts: [{ message: 'message' }] }}

    before :each do
      Broadcast.stubs(:by_repo).with(build.repository_id).returns([broadcast])
    end

    def notify
      subject.notify(event, build)
    end

    it 'triggers a task if the build is a push request' do
      build.stubs(:pull_request?).returns(false)
      task.expects(:run).with(:email, payload, params)
      notify
    end

    it 'triggers a task if the build is a pul request' do
      build.stubs(:pull_request?).returns(true)
      task.expects(:run).with(:email, payload, params)
      notify
    end

    it 'triggers a task if specified by the config' do
      Travis::Event::Config.any_instance.stubs(:enabled?).with(:email).returns(false)
      task.expects(:run).never
      notify
    end

    it 'does not trigger task if specified by the config' do
      Travis::Event::Config.any_instance.stubs(:enabled?).with(:email).returns(true)
      task.expects(:run).with(:email, payload, params)
      notify
    end
  end

  describe 'recipients' do
    let(:handler) { subject.new('build:finished', build, {}, payload) }

    it 'equals the recipients specified in the build configuration if any (given as an array)' do
      recipients = %w(recipient-1@email.com recipient-2@email.com)
      build.stubs(config: { notifications: { recipients: recipients } })
      handler.recipients.should contain_recipients(recipients)
    end

    it 'equals the recipients specified in the build configuration if any (given as a string)' do
      recipients = 'recipient-1@email.com,recipient-2@email.com'
      build.stubs(config: { notifications: { recipients: recipients } })
      handler.recipients.should contain_recipients(recipients)
    end

    it 'contains the author emails if the build has them set' do
      build.commit.stubs(author_email: 'author-1@email.com,author-2@email.com')
      handler.recipients.should contain_recipients(build.commit.author_email)
    end

    it 'contains the committer emails if the build has them set' do
      build.commit.stubs(committer_email: 'committer-1@email.com,committer-2@email.com')
      handler.recipients.should contain_recipients(build.commit.committer_email)
    end

    it 'contains the build repository owner_email if it has one' do
      build.repository.stubs(owner_email: 'owner-1@email.com,owner-2@email.com')
      handler.recipients.should contain_recipients(build.commit.committer_email)
    end

    it 'contains the build repository owner_email if it has a configuration but no emails specified' do
      build.stubs(config: {})
      build.repository.stubs(owner_email: 'owner-1@email.com')
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
  #     Metriks.expects(:timer).with('v1.travis.event.handler.email.notify:completed').returns(stub('timer', update: true))
  #     Travis::Event.dispatch('build:finished', build)
  #   end
  # end
end
