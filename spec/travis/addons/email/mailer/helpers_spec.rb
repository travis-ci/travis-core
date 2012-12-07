require 'spec_helper'

describe Travis::Addons::Email::Mailer::Helpers do
  include Travis::Addons::Email::Mailer::Helpers, Travis::Testing::Stubs

  it '#title returns title for the build' do
    title(repository).should == 'Build Update for svenfuchs/minimal'
  end
end
