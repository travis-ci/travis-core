require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe 'JSON for pusher' do
  include Support::ActiveRecord, Support::Formats

  let(:test) { Factory(:test) }

  it 'build:removed' do
    json_for_pusher('build:removed', test).should == {
     'build' => {
       'id' => test.id,
       'number' => '2.1'
      },
      'repository' => {
        'id' => test.repository_id,
        'slug' => 'svenfuchs/minimal'
      }
    }
  end
end
