require 'spec_helper'

describe Travis::Addons::Email::EventHandler do
  include Travis::Testing::Stubs

  let(:build)   { stub_build(state: :failed, repository: repository) }
  let(:subject) { Travis::Addons::Email::EventHandler }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }
  let(:repository) {
    stub_repo(users: [stub_user(email: 'author-1@email.com'), stub_user(email: 'committer-1@email.com')])
  }

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
      Broadcast.stubs(:by_repo).with(build.repository).returns([broadcast])
      build.stubs(:on_default_branch?).returns(true)
    end

    def notify
      subject.notify(event, build)
    end

    it 'triggers a task if the build is a push request' do
      build.stubs(:pull_request?).returns(false)
      notify
    end

    it 'does not trigger a task if the build is a pull request' do
      build.stubs(:pull_request?).returns(true)
      task.expects(:run).never
      notify
    end

    it 'triggers a task if specified by the config' do
      build.stubs(config: { notifications: { email: { recipients: 'svenfuchs@artweb-design.de' } } })
      task.expects(:run).with(:email, payload, params)
      notify
    end

    it 'does not trigger task if specified by the config' do
      build.stubs(config: { notifications: { email: false } })
      task.expects(:run).never
      notify
    end
  end

  describe '#recipients' do
    let(:handler) { subject.new('build:finished', build, {}, payload) }

    context 'when commit is on default branch' do
      before :each do
        build.stubs(:on_default_branch?).returns(true)
      end

      it 'equals the recipients specified in the build configuration if any (given as an array)' do
        recipients = %w(recipient-1@email.com)
        build.stubs(config: { notifications: { recipients: recipients } })
        handler.recipients.should contain_recipients(recipients)
      end

      it 'equals the recipients specified in the build configuration if any (given as a string)' do
        recipients = 'recipient-1@email.com'
        build.stubs(config: { notifications: { recipients: recipients } })
        handler.recipients.should contain_recipients(recipients)
      end

    end

    context 'when commit is on non-default branch' do

      let(:build) {
        stub_build(
          on_default_branch?: false,
          commit: stub_commit(author_email: 'author-1@email.com'),
          repository: repository
        )
      }

      it 'contains the author emails if the build has them set' do
        handler.recipients.should contain_recipients(build.commit.author_email)
      end

      it 'contains the committer emails if the build has them set' do
        build.commit.stubs(committer_email: 'committer-1@email.com')
        handler.recipients.should contain_recipients(build.commit.committer_email)
      end
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
