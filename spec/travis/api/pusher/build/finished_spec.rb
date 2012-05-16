require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Pusher::Build::Finished do
  include Support::Stubs, Support::Formats

  let(:data)  { Travis::Api::Pusher::Build::Finished.new(build).data }

  it 'equals the http v2 api payload for the build' do
    data.should == Travis::Api::Http::V2::Build.new(build).data
  end
end
