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

  describe 'timeouts' do
    MAX = {
      off: { hard_limit: 50, log_silence: 10 },
      on:  { hard_limit: 180, log_silence: 60 }
    }

    [:hard_limit, :log_silence].each do |type|
      describe type do
        def settings(type, value)
          Repository::Settings.new(:"timeout_#{type}" => value, repository_id: 1)
        end

        it 'defaults to nil' do
          settings(type, nil).send(:"timeout_#{type}").should be_nil
        end

        it "is valid if #{type} is > 0" do
          settings(type, nil).should be_valid
        end

        [:off, :on].each do |status|
          describe "with :custom_timeouts feature flag turned #{status}" do
            max = MAX[status][type]

            before :each do
              Travis::Features.stubs(:repository_active?).with(:custom_timeouts, 1).returns true if status == :on
            end

            it "is valid if #{type} is nil" do
              settings(type, nil).should be_valid
            end

            it "is valid if #{type} is 0" do
              settings(type, 0).should be_valid
            end

            it "is valid if #{type} is < #{max}" do
              settings(type, max - 1).should be_valid
            end

            it "is valid if #{type} equals #{max}" do
              settings(type, max).should be_valid
            end
          end
        end
      end
    end
  end
end
