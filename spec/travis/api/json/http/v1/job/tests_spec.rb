require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Json::Http::V1::Job::Tests do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::Json::Http::V1::Job::Tests.new([test]).data }

  it 'tests' do
    data.first.should == {
      'id' => test.id,
      'repository_id' => test.repository_id,
      'number' => '2.1',
      'queue' => 'builds.common',
      'state' => 'finished',
      'allow_failure' => false
    }
  end
end

