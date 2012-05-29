require 'spec_helper'
require 'support/active_record'

# A more high-level test for notifications as a whole
describe Travis::Event do
  include Travis::Event
  include Support::ActiveRecord

  let(:build) do
    Factory(:build, :config => { 'notifications' => { 'irc' => { 'channels' => ['irc.freenode.net#####example'] } } })
  end

  describe "irc" do
    before do
      Travis.config.notifications = [:irc]
    end

    it "should handle channel names with several '#'s in front of it" do
      build.irc_channels.should == {['irc.freenode.net', nil] => ['####example']}
    end
  end
end
