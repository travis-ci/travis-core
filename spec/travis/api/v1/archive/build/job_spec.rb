require 'spec_helper'

describe Travis::Api::V1::Archive::Build do
  include Travis::Testing::Stubs

  context 'without log' do
    let(:data) do
      test = stub_test
      test.stubs :log => nil, :log_content => nil
      Travis::Api::V1::Archive::Build::Job.new(test).data
    end

    it 'returns null as a log content' do
      data['log'].should be_nil
    end
  end
end
