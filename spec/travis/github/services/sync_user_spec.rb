require 'spec_helper'

describe Travis::Github::Services::SyncUser do
  include Support::ActiveRecord

  let(:user)    { Factory(:user) }
  let(:service) { described_class.new(user) }

  describe 'syncing' do
    it 'returns the block value' do
      service.send(:syncing) { 42 }.should == 42
    end

    it 'sets is_syncing?' do
      user.is_syncing = false
      user.should_not be_syncing
      service.send(:syncing) { user.should be_syncing }
      user.should_not be_syncing
    end

    it 'starts syncing after create' do
      user.should be_syncing
    end

    it 'sets synced_at' do
      time = Time.now
      service.send(:syncing) { }
      user.synced_at.should >= time
    end

    it 'raises exceptions' do
      exception = nil
      expect { service.send(:syncing) { raise('kaputt') } }.to raise_error
    end

    it 'ensures the user is set back to not sycing when an exception raises' do
      service.send(:syncing) { raise('kaputt') } rescue nil
      user.should_not be_syncing
    end
  end
end
