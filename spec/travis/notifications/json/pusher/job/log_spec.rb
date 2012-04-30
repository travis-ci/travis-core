require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe Travis::Notifications::Json::Pusher::Job::Log do
  include Support::ActiveRecord, Support::Formats

  let(:test) { Factory(:test) }
  let(:data) { Travis::Notifications::Json::Pusher::Job::Log.new(test).data }

  it 'data' do
    data.should == {
      'id' => test.id
    }
  end
end
