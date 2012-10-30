require 'spec_helper'

describe Travis::Services::Github::SyncUser do
  include Support::ActiveRecord

  let(:subject) { Travis::Services::Github::SyncUser }
  let(:user)    { Factory(:user) }
  let(:service) { subject.new(user) }

  describe 'syncing' do
    it 'returns the block value' do
      service.send(:syncing) { 42 }.should == 42
    end

    it 'sets is_syncing?' do
      user.should_not be_syncing
      service.send(:syncing) { user.should be_syncing }
      user.should_not be_syncing
    end

    it 'sets synced_at' do
      time = Time.now
      service.send(:syncing) { }
      user.synced_at.should >= time
    end

    it 'handles exceptions' do
      exception = nil
      Travis::Exceptions.expects(:handle).with { |e| e.message.should == 'kaputt' }
      service.send(:syncing) { raise('kaputt') }
    end
  end
end
