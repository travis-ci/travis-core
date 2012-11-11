require 'spec_helper'

describe Travis::Api::V1::Http::Hooks do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V1::Http::Hooks.new([repository]).data }

  it 'data' do
    data.first.should == {
      'uid' => 'svenfuchs:minimal',
      'url' => 'https://github.com/svenfuchs/minimal',
      'name' => 'minimal',
      'owner_name' => 'svenfuchs',
      'description' => 'the repo description',
      'active' => true,
      'private' => false
    }
  end
end

