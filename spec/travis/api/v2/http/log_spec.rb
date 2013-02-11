require 'spec_helper'

describe Travis::Api::V2::Http::Log do
  include Travis::Testing::Stubs

  let(:data) { described_class.new(log).data }

  it 'log' do
    data['log'].should == {
      'id' => 1,
      'job_id' => 1,
      'type' => 'Log',
      'body' => 'the test log'
    }
  end
end
