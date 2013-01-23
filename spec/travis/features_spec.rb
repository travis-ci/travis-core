require 'spec_helper'

describe Travis::Features do
  before do
    Travis.instance_variable_set(:@config, nil)
  end

    it "should delegate to rollout" do
      expect { Travis::Features.info(:short_urls) }.to_not raise_error
    end

  describe "feature checks" do
    include Support::ActiveRecord

    before do
      Travis::Features.activate_all(:feature)
    end

    after do
      Travis::Features.deactivate_user(:feature, user)
      Travis::Features.deactivate_repository(:feature, repository)
      Travis::Features.deactivate_all(:feature)
    end

    let(:repository) {Factory(:repository)}
    let!(:user) {Factory(:user)}

    it "should return true if the repository's owner is activated" do
      expect {
        Travis::Features.activate_user(:feature, user)
      }.to change {Travis::Features.active?(:feature, repository)}
    end

    it "should return false if the repository's owner isn't activated" do
      Travis::Features.active?(:feature, repository).should == false
    end

    it "should allow enabling the repository" do
      Travis::Features.activate_repository(:feature, repository)
    end

    it "should be active when the repository was activated" do
      expect {
        Travis::Features.activate_repository(:feature, repository)
      }.to change {Travis::Features.active?(:feature, repository)}
    end

    it "shouldn't be active when the repository was deactivated" do
      Travis::Features.activate_repository(:feature, repository)
      expect {
        Travis::Features.deactivate_repository(:feature, repository)
      }.to change {Travis::Features.active?(:feature, repository)}
    end

    describe "for users" do
      it "should be active when enabled for a user" do
        Travis::Features.activate_user(:feature, user)
        Travis::Features.user_active?(:feature, user).should == true
      end

      it "shouldn't be active when disable for a user" do
        Travis::Features.deactivate_user(:feature, user)
        Travis::Features.user_active?(:feature, user).should == false
      end
    end

    describe "for features" do
      it "should allow enabling features completely" do
        Travis::Features.enable_for_all(:feature)
        Travis::Features.active?(:feature, repository).should == true
      end

      it "shouldn't be active when the feature was disabled completely" do
        Travis::Features.enable_for_all(:feature)
        expect {
          Travis::Features.disable_for_all(:feature)
        }.to change {
          Travis::Features.active?(:feature, repository)
        }
      end
    end
  end
end
