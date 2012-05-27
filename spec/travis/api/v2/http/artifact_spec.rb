require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::V2::Http::Build do
  include Support::Formats, Support::Stubs

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
