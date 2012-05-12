require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Http::V2::Tests do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::Http::V2::Tests.new([test]).data }

  it 'jobs' do
    data['jobs'].first.should == {
      'id' => test.id,
      'repository_id' => test.repository_id,
      'number' => '2.1',
      'queue' => 'builds.common',
      'state' => 'finished',
    }
  end
end

