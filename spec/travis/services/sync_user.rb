require 'spec_helper'

describe Travis::Services::SyncUser do
  include Travis::Testing::Stubs

  let(:publisher) { stub('publisher', :publish => true) }
  let(:service)   { described_class.new(user, {}) }

  before :each do
    Travis::Amqp::Publisher.stubs(:new).returns(publisher)
    user.stubs(:update_column)
  end

  describe 'given the user is not currently syncing' do
    before :each do
      user.stubs(:syncing?).returns(false)
    end

    it 'enqueues a sync job' do
      publisher.expects(:publish).with({ :user_id => user.id }, :type => 'sync')
      service.run
    end

    it 'sets the user to syncing' do
      user.expects(:update_column).with(:is_syncing, true)
      service.run
    end
  end

  describe 'given the user is currently syncing' do
    before :each do
      user.stubs(:syncing?).returns(false)
    end

    it 'does not enqueue a sync job' do
      publisher.expects(:publish).never
      service.run
    end

    it 'does not set the user to syncing' do
      user.expects(:update_column).never
      service.run
    end
  end

  describe 'with sidekiq enabled' do
    before do
      user.update_column(:is_syncing, false)
      Travis::Features.enable_for_all(:sync_via_sidekiq)
    end

    after do
      Travis::Features.disable_for_all(:sync_via_sidekiq)
    end

    it "should publish to sidekiq" do
      Travis::Sidekiq::SynchronizeUser.expects(:perform_async)
      service.run
    end

    it "shouldn't publish to amqp" do
      publisher.expects(:publish).never
      service.run
    end

    it "should set the user to syncing" do
      user.expects(:update_column).with(:is_syncing, true)
      service.run
    end

    context "for the current user" do
      before do
        Travis::Features.disable_for_all(:sync_via_sidekiq)
      end

      after do
        Travis::Features.deactivate_user(:sync_via_sidekiq, user)
      end

      it "should allow syncing if the current user is flipped" do
        Travis::Features.activate_user(:sync_via_sidekiq, user)
        Travis::Sidekiq::SynchronizeUser.expects(:perform_async)
        service.run
      end

      it "should sync via AMQP if the current user isn't flipped" do
        Travis::Sidekiq::SynchronizeUser.expects(:perform_async).never
        service.run
      end
    end
  end
end
