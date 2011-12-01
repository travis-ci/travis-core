require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe 'JSON for pusher' do
  include Support::ActiveRecord, Support::Formats

  let(:build) { Factory(:build) }

  it 'build:finished' do
    json_for_pusher('build:finished', build).should == {
      'build' => {
        'id' => build.id,
        'result' => 0,
        'finished_at' => json_format_time(Time.now.utc)
      },
      'repository' => {
        'id' => build.repository_id,
        'slug' => 'svenfuchs/minimal',
        'last_build_id' => 2,
        'last_build_number' => '2',
        'last_build_started_at' => json_format_time(Time.now.utc),
        'last_build_finished_at' => json_format_time(Time.now.utc),
        'last_build_result' => 0
      }
    }
  end
end
