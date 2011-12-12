require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe 'JSON for pusher' do
  include Support::ActiveRecord, Support::Formats

  let(:job) { Factory(:test) }

  it 'job:log' do
    json_for_pusher('job:log', job).should == {
      'id' => job.id
    }
  end
end
