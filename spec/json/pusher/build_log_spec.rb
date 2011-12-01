require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe 'JSON for pusher' do
  include Support::ActiveRecord, Support::Formats

  let(:build) { Factory(:build) }

  it 'build:log' do
    json_for_pusher('build:log', build).should == {
      'build' => {
        'id' => build.id,
      },
      'repository' => {
        'id' => build.repository_id,
      }
    }
  end
end
