require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe 'JSON for pusher' do
  include Support::ActiveRecord, Support::Formats

  let(:test) { Factory(:test) }

  it 'job:started' do
    json_for_pusher('job:started', test).should == {
      'id' => test.id,
      'started_at' => nil
    }
  end
end
