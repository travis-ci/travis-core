require 'spec_helper'

describe Travis::Api::V2::Http::Artifact do
  include Travis::Testing::Stubs

  let(:data) { Travis::Api::V2::Http::Artifact.new(log).data }

  it 'artifact' do
    data['artifact'].should == {
      'id' => 1,
      'job_id' => 1,
      'type' => 'Log',
      'body' => 'the test log'
    }
  end
end
