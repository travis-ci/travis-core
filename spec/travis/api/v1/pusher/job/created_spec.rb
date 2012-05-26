require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::V1::Pusher::Job::Created do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::V1::Pusher::Job::Created.new(test).data }

  it 'data' do
    data.should == {
      'id' => test.id,
      'build_id' => test.source_id,
      'repository_id' => test.repository_id,
      'number' => '2.1',
      'queue' => 'builds.common',
    }
  end
end
