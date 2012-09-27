require 'spec_helper'

describe Travis::Services::User do
  include Travis::Testing::Stubs

  let(:service)   { Travis::Services::User.new(user) }
  let(:publisher) { stub('publisher', :publish => true) }

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
        service.sync
      end

      it 'sets the user to syncing' do
        user.expects(:update_column).with(:is_syncing, true)
        service.sync
      end
    end

    describe 'given the user is currently syncing' do
      before :each do
        user.stubs(:syncing?).returns(false)
      end

      it 'does not enqueue a sync job' do
        publisher.expects(:publish).never
        service.sync
      end

      it 'does not set the user to syncing' do
        user.expects(:update_column).never
        service.sync
      end
    end
  end

  describe 'update_locale' do
    it 'updates the locale if valid' do
      user.expects(:update_column).with(:locale, 'en')
      service.update_locale('en')
    end

    it 'does not update the locale if invalid' do
      user.expects(:update_column).never
      service.update_locale('en')
    end
  end
end


