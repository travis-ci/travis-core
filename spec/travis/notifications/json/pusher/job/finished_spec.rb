require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe Travis::Notifications::Json::Pusher::Job::Finished do
  include Support::ActiveRecord, Support::Formats

  let(:test) { Factory(:test) }
  let(:data) { Travis::Notifications::Json::Pusher::Job::Finished.new(test).data }

  it 'data' do
    data.should == {
      'id' => test.id,
      'build_id' => test.source_id,
      'finished_at' => nil,
      'result' => nil
    }
  end
end

