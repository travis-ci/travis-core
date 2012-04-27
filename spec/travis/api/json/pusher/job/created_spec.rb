require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe Travis::Api::Json::Pusher::Job::Created do
  include Support::ActiveRecord, Support::Formats

  let(:test) { Factory(:test) }
  let(:data) { Travis::Api::Json::Pusher::Job::Created.new(test).data }

  it 'data' do
    data.should == {
      'id' => test.id,
      'build_id' => test.source_id,
      'repository_id' => test.repository_id,
      'number' => '2.1',
      'queue' => 'builds.common',
    }
  end
end
