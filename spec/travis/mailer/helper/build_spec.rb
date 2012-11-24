require 'spec_helper'

describe Travis::Mailer::Helper::Build do
  include Travis::Mailer::Helper::Build, Travis::Testing::Stubs

  it '#title returns title for the build' do
    title(repository).should == 'Build Update for svenfuchs/minimal'
  end
end
