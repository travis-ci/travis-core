require 'spec_helper'

describe Travis::Api::V2::Http::User do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V2::Http::User.new(user).data }

  it 'data' do
    data['user'].should == {
      'login' => 'svenfuchs',
      'name' => 'Sven Fuchs',
      'email' => 'svenfuchs@artweb-design.de',
      'gravatar_id' => '402602a60e500e85f2f5dc1ff3648ecb',
      'locale' => 'de',
      'is_syncing' => false,
      'synced_at' => json_format_time(Time.now.utc - 1.hour)
    }
  end
end

