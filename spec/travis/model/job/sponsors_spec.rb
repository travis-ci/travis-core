require 'spec_helper'

class SponsorsMock
  include Job::Sponsors
  attr_accessor :state, :tags, :log, :config
end

describe Job::Tagging do
  let(:sponsors) do
    YAML.load <<-yml
      ruby1.worker.travis-ci.org:
        name: Avarteq
        url: http://avarteq.de
      ruby2.worker.travis-ci.org:
        name: Railslove
        url: http://railslove.de
    yml
  end

  let(:log) do
    stub('log', :content => "Using worker: ruby2.worker.travis-ci.org:travis-ruby-4\n$ cd ~/builds")
  end

  let(:job) { SponsorsMock.new.tap { |job| job.log = log } }

  before :each do
    Job::Sponsors.stubs(:sponsors).returns(sponsors)
  end

  describe :worker do
    it 'returns the worker name extracted from the log' do
      job.worker.should == 'ruby2.worker.travis-ci.org'
    end
  end

  describe :sponsor do
    it 'returns the sponsor for the current test' do
      job.sponsor.name.should == 'Railslove'
    end
  end

  describe :prepend_sponsor do
    it 'prepends a sponsor message to the log' do
      job.log.expects(:prepend).with(%(Sponsored by <a href="http://railslove.de">Railslove</a>\n))
      job.prepend_sponsor
    end
  end
end


