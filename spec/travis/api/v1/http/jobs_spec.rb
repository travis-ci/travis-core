require 'spec_helper'

describe Travis::Api::V1::Http::Jobs do
  include Travis::Testing::Stubs

  let(:data) { Travis::Api::V1::Http::Jobs.new([test]).data }

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

