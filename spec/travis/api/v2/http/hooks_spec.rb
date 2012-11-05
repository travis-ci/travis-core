require 'spec_helper'

describe Travis::Api::V2::Http::Hooks do
  include Travis::Testing::Stubs

  let(:data) { Travis::Api::V2::Http::Hooks.new([hook]).data }

  it 'hooks' do
    data['hooks'].should == [
      {
        'id' => 1,
        'owner_name' => 'travis-ci',
        'name' => 'travis-ci',
        'description' => 'description',
        'active' => true,
        'private' => false
      }
    ]
  end
end
