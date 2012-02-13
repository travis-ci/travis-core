require 'spec_helper'

class SponsorsMock
  include Job::Sponsors
  attr_accessor :state, :tags, :log, :config
  def read_attribute(*); end
end

describe Job::Tagging do
  let(:log) { stub('log', :content => "Using worker: ruby3.worker.travis-ci.org:travis-ruby-4\n$ cd ~/builds") }
  let(:job) { SponsorsMock.new.tap { |job| job.log = log } }

  before :each do
    Travis.config.sponsors.workers = {
      'ruby3.worker.travis-ci.org' => {
        'name' => 'Railslove',
        'url' => 'http://railslove.de'
      }
    }
  end

  describe :worker do
    it 'returns the worker name extracted from the log' do
      job.worker.should == 'ruby3.worker.travis-ci.org:travis-ruby-4'
    end
  end

  describe :sponsor do
    it 'returns the sponsor for the current test' do
      job.sponsor.name.should == 'Railslove'
    end
  end
end


