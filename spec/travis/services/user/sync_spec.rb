require 'spec_helper'

describe Travis::Services::User::Sync do
  include Travis::Testing::Stubs

  let(:publisher) { stub('publisher', :publish => true) }
  let(:service)   { Travis::Services::User::Sync.new(user, {}) }

  before :each do
    Travis::Amqp::Publisher.stubs(:new).returns(publisher)
    user.stubs(:update_column)
  end

  describe 'sync' do
    describe 'given the user is not currently syncing' do
      before :each do
        user.stubs(:syncing?).returns(false)
      end

      it 'enqueues a sync job' do
        publisher.expects(:publish).with({ user_id: user.id }, type: 'sync')
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
  end
end
