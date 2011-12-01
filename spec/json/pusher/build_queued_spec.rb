require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe 'JSON for pusher' do
  include Support::ActiveRecord, Support::Formats

  let(:test) { Factory(:test) }

  it 'build:queued' do
    json_for_pusher('build:queued', test).should == {
     'build' => {
       'id' => test.id,
       'number' => '2.1',
       'queue' => 'builds.common'
      },
      'repository' => {
        'id' => test.repository_id,
        'slug' => 'svenfuchs/minimal'
      }
    }
  end
end
