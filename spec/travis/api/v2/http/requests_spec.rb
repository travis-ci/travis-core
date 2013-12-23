require 'spec_helper'

describe Travis::Api::V2::Http::Requests do
  include Travis::Testing::Stubs

  let(:data) {
    Travis::Api::V2::Http::Requests.new([request]).data
  }

  it 'returns requests data' do
    data['requests'].should == [
      {
        'id' => 1,
        'repository_id' => 1,
        'commit_id' => 1,
        'created_at' => 'Tue, 01 Jan 2013 00:00:00 +0000',
        'owner_id' => 1,
        'owner_type' => 'User',
        'event_type' => 'push',
        'base_commit' => 'base-commit',
        'head_commit' => 'head-commit',
        'result' => :accepted,
        'message'=>'a message'
      }
    ]
  end
end
