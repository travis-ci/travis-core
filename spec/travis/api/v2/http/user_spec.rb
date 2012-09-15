require 'spec_helper'

describe Travis::Api::V2::Http::User do
  include Travis::Testing::Stubs, Support::Formats

  let(:profile) { { :user => user, :accounts => [user, org], :repository_counts => { 'svenfuchs' => 2, 'travis-ci' => 1 } } }
  let(:data)    { Travis::Api::V2::Http::User.new(profile).data }

  it 'user' do
    data['user'].should == {
      'id' => 1,
      'name' => 'Sven Fuchs',
      'login' => 'svenfuchs',
      'email' => 'svenfuchs@artweb-design.de',
      'gravatar_id' => '402602a60e500e85f2f5dc1ff3648ecb',
      'locale' => 'de',
      'is_syncing' => false,
      'synced_at' => json_format_time(Time.now.utc - 1.hour)
    }
  end

  it 'accounts' do
    data['accounts'].should == [
      { 'id' => 1, 'login' => user.login, 'name' => user.name, 'type' => 'user', 'reposCount' => 2 },
      { 'id' => 1, 'login' => org.login, 'name' => org.name, 'type' => 'org', 'reposCount' => 1 }
    ]
  end
end

