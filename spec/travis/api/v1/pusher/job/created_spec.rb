require 'spec_helper'

describe Travis::Api::V1::Pusher::Job::Created do
  include Travis::Testing::Stubs

  let(:data) { Travis::Api::V1::Pusher::Job::Created.new(test).data }

  it 'data' do
    data.should == {
      'id' => test.id,
      'build_id' => test.source_id,
      'repository_id' => test.repository_id,
      'number' => '2.1',
      'queue' => 'builds.common',
      'state' => 'finished',
      'log_id' => 1,
      'allow_failure' => false
    }
  end
end
