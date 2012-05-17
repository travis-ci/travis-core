require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Http::V2::Repository do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::Http::V2::Repository.new(repository).data }

  it 'repository' do
    data['repository'].should == {
      'id' => repository.id,
      'slug' => 'svenfuchs/minimal',
      'description' => 'the repo description',
      'last_build_id' => 1,
      'last_build_number' => 2,
      'last_build_started_at' => json_format_time(Time.now.utc - 1.minute),
      'last_build_finished_at' => json_format_time(Time.now.utc),
      'last_build_result' => 0,
      'last_build_language' => 'ruby',
      'last_build_duration' => 60,
    }
  end
end
