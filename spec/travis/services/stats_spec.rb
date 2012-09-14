require 'spec_helper'
require 'travis/testing/scenario'

describe Travis::Services::Stats do
  include Support::ActiveRecord

  let(:service) { Travis::Services::Stats.new }

  before { Scenario.default }

  describe "when listing daily test counts" do
    it "should return the jobs per day" do
      stats = service.daily_tests_counts
      stats.should have(1).item
      stats.first[:date].should == Job.first.created_at.to_date.to_s(:date)
      stats.first[:run_on_date].should == 13
    end
  end

  describe "when listing total repositories" do
    it "should include the date" do
      stats = service.daily_repository_counts
      stats.should have(1).items
      stats.first[:date].should == Repository.first.created_at.to_date.to_s(:date)
    end

    it "should include the number per day" do
      stats = service.daily_repository_counts
      stats.should have(1).items
      stats.first[:added_on_date].should == 2
    end

    it "should include the total growth" do
      stats = service.daily_repository_counts
      stats.should have(1).items
      stats.first[:total_growth].should == 2
    end
  end
end


