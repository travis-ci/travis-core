require 'spec_helper'

describe Travis::Api::V1::Pusher::Job::Created do
  include Travis::Testing::Stubs

  let(:test) { stub_test(state: :created, started_at: nil, finished_at: nil) }
  let(:data) { Travis::Api::V1::Pusher::Job::Created.new(test).data }

  it 'data' do
    data.should == {
      'id' => test.id,
      'build_id' => test.source_id,
      'repository_id' => test.repository_id,
      'repository_slug' => 'svenfuchs/minimal',
      'number' => '2.1',
      'state' => 'created',
      'result' => nil,
      'queue' => 'builds.linux',
      'log_id' => 1,
      'allow_failure' => false
    }
  end

  context 'without log' do
    before { test.stubs(log_id: nil) }

    it 'returns null log_id' do
      data['log_id'].should be_nil
    end
  end
end
