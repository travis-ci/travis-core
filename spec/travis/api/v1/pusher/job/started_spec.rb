require 'spec_helper'

describe Travis::Api::V1::Pusher::Job::Started do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { Travis::Api::V1::Pusher::Job::Started.new(test).data }

  before :each do
    Travis.config.sponsors.workers = {
      'ruby3.worker.travis-ci.org' => {
        'name' => 'Railslove',
        'url' => 'http://railslove.de'
      }
    }
  end

  it 'data' do
    data.should == {
      'id' => 1,
      'build_id' => 1,
      'repository_id' => 1,
      'started_at' => json_format_time(Time.now.utc - 1.minute),
      'worker' => 'ruby3.worker.travis-ci.org:travis-ruby-4',
      'sponsor' => { 'name' => 'Railslove', 'url' => 'http://railslove.de' },
      'state' => 'finished'
    }
  end
end

