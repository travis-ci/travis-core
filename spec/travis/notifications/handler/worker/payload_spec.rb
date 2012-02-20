require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::Handler::Worker::Payload do
  Payload = Travis::Notifications::Handler::Worker::Payload

  let(:configure) { Factory(:configure) }
  let(:test)      { Factory(:test) }

  describe 'for returns the payload required for worker jobs' do
    it 'Job::Configure' do
      Payload.for(configure).keys.should == [:build, :repository, :queue]
    end

    it 'Job::Test' do
      Payload.for(test).keys.should == [:build, :repository, :config, :queue]
    end
  end
end
