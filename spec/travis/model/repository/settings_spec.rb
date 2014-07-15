# encoding: utf-8
require 'spec_helper'

describe Repository::Settings do
  describe '#maximum_number_of_builds' do
    it 'returns integer' do
      settings = Repository::Settings.new(maximum_number_of_builds: nil)
      settings.maximum_number_of_builds.should == 0
    end
  end

  describe '#restricts_number_of_builds?' do
    it 'returns true if number of builds is restricted' do
      settings = Repository::Settings.new(maximum_number_of_builds: 2)
      settings.restricts_number_of_builds?.should be_true
    end

    it 'returns false if builds are not restricted' do
      settings = Repository::Settings.new(maximum_number_of_builds: 0)
      settings.restricts_number_of_builds?.should be_false
    end
  end

  it 'validates maximum_number_of_builds' do
    settings = Repository::Settings.new
    settings.maximum_number_of_builds = nil
    settings.should be_valid

    settings.maximum_number_of_builds = 'foo'
    settings.should_not be_valid

    settings.errors[:maximum_number_of_builds].should == [:not_a_number]

    settings.maximum_number_of_builds = 0
    settings.should be_valid
  end
end
