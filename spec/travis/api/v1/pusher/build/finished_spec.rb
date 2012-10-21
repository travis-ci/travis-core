require 'spec_helper'

describe Travis::Api::V1::Pusher::Build::Finished do
  include Travis::Testing::Stubs, Support::Formats

  let(:data)  { Travis::Api::V1::Pusher::Build::Finished.new(build).data }

  it 'build' do
    data['build'].should == {
      'id' => build.id,
      'result' => 0,
      'finished_at' => json_format_time(Time.now.utc),
      'state' => 'finished',
      'duration' => 60
    }
  end

  it 'repository' do
    data['repository'].should == {
      'id' => build.repository_id,
      'slug' => 'svenfuchs/minimal',
      'last_build_id' => 1,
      'last_build_number' => 2,
      'last_build_started_at' => json_format_time(Time.now.utc - 1.minute),
      'last_build_finished_at' => json_format_time(Time.now.utc),
      'last_build_result' => 0,
      'last_build_duration' => 60
    }
  end
end
