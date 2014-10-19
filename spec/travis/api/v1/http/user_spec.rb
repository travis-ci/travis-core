require 'spec_helper'

describe Travis::Api::V1::Http::User do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V1::Http::User.new(user).data }

  it 'data' do
    data.should == {
      'login' => 'svenfuchs',
      'name' => 'Sven Fuchs',
      'email' => 'svenfuchs@artweb-design.de',
      'avatar_url' => 'https://avatars2.githubusercontent.com/u/2208',
      'locale' => 'de',
      'is_syncing' => false,
      'synced_at' => json_format_time(Time.now.utc - 1.hour)
    }
  end
end
