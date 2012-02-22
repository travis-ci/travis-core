require 'spec_helper'
require 'support/active_record'
require 'support/webmock'

describe User do
  include Support::ActiveRecord, Support::Webmock

  let(:user)    { FactoryGirl.build(:user) }
  let(:payload) { GITHUB_PAYLOADS[:oauth] }

  describe 'find_or_create_for_oauth' do
    def user(payload)
      User.find_or_create_for_oauth(payload)
    end

    it 'marks new users as such' do
      user(payload).should be_recently_signed_up
      user(payload).should_not be_recently_signed_up
    end

    it 'updates changed attributes' do
      user(payload).attributes.slice(*GITHUB_OAUTH_DATA.keys).should == GITHUB_OAUTH_DATA
    end
  end

  describe 'user_data_from_oauth' do
    it 'returns required data' do
      User.user_data_from_oauth(payload).should == GITHUB_OAUTH_DATA
    end
  end

  describe 'profile_image_hash' do
    it "returns gravatar_id if it's present" do
      user.gravatar_id = '41193cdbffbf06be0cdf231b28c54b18'
      user.profile_image_hash.should == '41193cdbffbf06be0cdf231b28c54b18'
    end

    it 'returns a MD5 hash of the email if no gravatar_id and an email is set' do
      user.gravatar_id = nil
      user.profile_image_hash.should == Digest::MD5.hexdigest(user.email)
    end

    it 'returns 32 zeros if no gravatar_id or email is set' do
      user.gravatar_id = nil
      user.email = nil
      user.profile_image_hash.should == '0' * 32
    end
  end

  describe 'github_service_hooks' do
    let!(:repository) { Factory(:repository, :name => 'safemode', :active => true) }

    it "contains the user's service_hooks (i.e. repository data from github)" do
      service_hook = user.github_service_hooks.first
      service_hook.uid.should == 'svenfuchs:safemode'
      service_hook.owner_name.should == 'svenfuchs'
      service_hook.name.should == 'safemode'
      service_hook.description.should include('A library for safe evaluation of Ruby code')
      service_hook.url.should == 'https://github.com/svenfuchs/safemode'
      service_hook.active.should be_true
    end
  end
end
