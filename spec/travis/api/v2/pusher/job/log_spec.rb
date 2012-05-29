require 'spec_helper'
require 'support/stubs'

describe Travis::Api::V2::Pusher::Job::Log do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::V2::Pusher::Job::Log.new(test).data }

  it 'data' do
    data.should == { 'job' => { 'id' => test.id } }
  end
end

