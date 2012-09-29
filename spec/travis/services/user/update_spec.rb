require 'spec_helper'

describe Travis::Services::User::Update do
  include Travis::Testing::Stubs

  let(:service)   { Travis::Services::User::Update.new(user, params) }

  before :each do
    user.stubs(:update_attributes!)
  end

  attr_reader :params

  describe 'update_locale' do
    it 'updates the locale if valid' do
      @params = { :locale => 'en' }
      user.expects(:update_attributes!).with(params)
      service.run
    end

    it 'does not update the locale if invalid' do
      @params = { :locale => 'foo' }
      user.expects(:update_attributes!).never
      service.run
    end
  end
end


