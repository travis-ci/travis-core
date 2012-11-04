require 'spec_helper'

describe Travis::Api::V2::Http::Hooks do
  include Travis::Testing::Stubs

  let(:data) { Travis::Api::V2::Http::Hooks.new([repository]).data }

  it 'hooks' do
    data['hooks'].should == [
      {
        'id' => 1,
        'name' => 'minimal',
        'owner_name' => 'svenfuchs',
        'description' => 'the repo description',
        'active' => true,
        'private' => false
      }
    ]
  end
end
