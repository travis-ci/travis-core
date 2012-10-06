require 'spec_helper'

describe Travis::Api::V2::Http::Permissions do
  include Travis::Testing::Stubs

  let(:permissions) do
    [stub(:repository_id => 1), stub(:repository_id => 2), stub(:repository_id => 3)]
  end

  let(:data) { Travis::Api::V2::Http::Permissions.new(permissions).data }

  it 'permissions' do
    data['permissions'].should == [1, 2, 3]
  end
end

