require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Pusher::Job::Created do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::Pusher::Job::Created.new(test).data }

  it 'equals the http v2 api payload for the job' do
    data.should == Travis::Api::Http::V2::Job.new(test).data
  end
end
