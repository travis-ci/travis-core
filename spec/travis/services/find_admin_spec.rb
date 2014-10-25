require 'spec_helper'

describe Travis::Services::FindAdmin do
  include Travis::Testing::Stubs

  describe 'find' do
    let(:admins)  { [stub_user(login: 'admin-1'), stub_user(login: 'admin_2')] }
    let(:result)  { described_class.new(nil, options.merge(repository: repo)).run }
    let(:options) { {} }

    before :each do
      repo.stubs(:admins).returns(admins)
    end

    describe 'with :validate not given' do
      it 'returns the first available admin' do
        result.should == admins.first
      end
    end

    describe 'with :validate given' do
      def expect_github_validate_admin(user)
        described_class.any_instance.expects(:run_service).with(:github_validate_admin, repo: repo, user: user)
      end

      let(:options) { { validate: true } }

      before :each do
        Travis::Features.stubs(:enabled_for_all?).with(:allow_validate_admin).returns(true)
      end

      it 'runs the :github_validate_admin service for each admin candidate' do
        expect_github_validate_admin(admins.first).returns(nil)
        expect_github_validate_admin(admins.last).returns(admins.last)
        result.should == admins.last
      end
    end

    describe 'if no repository was passed' do
      let(:repo) { nil }

      it 'raises Travis::RepositoryMissing' do
        -> { result }.should raise_error(Travis::RepositoryMissing)
      end
    end

    describe 'no admin could be found' do
      let(:admins) { [] }

      it 'raises Travis::AdminMissing' do
        -> { result }.should raise_error(Travis::AdminMissing, 'no admin available for svenfuchs/minimal')
      end
    end
  end
end

describe Travis::Services::FindAdmin::Instrument do
  include Travis::Testing::Stubs

  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }
  let(:service)   { Travis::Services::FindAdmin.new(nil, repository: repository) }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    repository.stubs(:admins).returns([user])
    GH.stubs(:[]).with("repos/#{repository.slug}").returns('permissions' => { 'admin' => true })
    service.run
  end

  it 'publishes a event' do
    event.should publish_instrumentation_event(
      event: 'travis.services.find_admin.run:completed',
      message: 'Travis::Services::FindAdmin#run:completed for svenfuchs/minimal: svenfuchs',
      result: user,
    )
  end
end
