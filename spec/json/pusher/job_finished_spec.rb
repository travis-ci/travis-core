require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe 'JSON for pusher' do
  include Support::ActiveRecord, Support::Formats

  let(:test) { Factory(:test) }

  it 'job:finished' do
    json_for_pusher('job:finished', test).should == {
      'id' => test.id,
      'build_id' => test.owner_id,
      'finished_at' => nil,
      'result' => nil
    }
  end
end
