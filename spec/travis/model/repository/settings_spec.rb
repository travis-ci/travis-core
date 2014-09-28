# encoding: utf-8
require 'spec_helper'

describe Repository::Settings do
  describe 'env_vars' do
    it 'can be filtered to get only public vars' do
      settings = Repository::Settings.load(env_vars: [
        { name: 'PUBLIC_VAR', value: 'public var', public: true },
        { name: 'SECRET_VAR', value: 'secret var', public: false }
      ])
      settings.env_vars.public.length.should == 1
      settings.env_vars.public.first.name.should == 'PUBLIC_VAR'
    end
  end

  describe '#maximum_number_of_builds' do
    it 'defaults to 0' do
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

  describe '#timeout_hard_limit' do
    it 'defaults to nil' do
      settings = Repository::Settings.new(timeout_hard_limit: nil)
      settings.timeout_hard_limit.should be_nil
    end
  end

  describe '#timeout_log_silence' do
    it 'defaults to nil' do
      settings = Repository::Settings.new(timeout_log_silence: nil)
      settings.timeout_log_silence.should be_nil
    end
  end
end
