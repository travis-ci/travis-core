require 'spec_helper'

describe Travis::Services::Base do
  let(:user) { stub('user') }

  it 'allows passing dependencies' do
    service = Travis::Services::Base.new(:user => user)
    service.user.should == user
  end
end
