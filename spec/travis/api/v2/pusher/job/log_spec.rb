require 'spec_helper'

describe Travis::Api::V2::Pusher::Job::Log do
  include Travis::Testing::Stubs

  let(:data) { Travis::Api::V2::Pusher::Job::Log.new(test).data }

  it 'data' do
    data.should == { 'job' => { 'id' => test.id } }
  end
end

