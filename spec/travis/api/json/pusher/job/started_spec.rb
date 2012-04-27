require 'spec_helper'
require 'support/active_record'
require 'support/formats'

describe Travis::Api::Json::Pusher::Job::Started do
  include Support::ActiveRecord, Support::Formats

  let(:test) { Factory(:test, :worker => 'ruby3.worker.travis-ci.org:travis-ruby-4') }
  let(:data) { Travis::Api::Json::Pusher::Job::Started.new(test).data }

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
      'id' => test.id,
      'build_id' => test.source_id,
      'started_at' => nil,
      'worker' => 'ruby3.worker.travis-ci.org:travis-ruby-4',
      'sponsor' => { 'name' => 'Railslove', 'url' => 'http://railslove.de' }
    }
  end
end

