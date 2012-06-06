require 'spec_helper'

describe Travis::Mailer::Helper::Build do
  include Travis::Mailer::Helper::Build, Travis::Testing::Stubs

  it '#title returns title for the build' do
    title(repository).should == 'Build Update for svenfuchs/minimal'
  end

  describe 'header_result' do
    it 'returns success header class for a successful build' do
      build.stubs(:result).returns(0)
      header_result(build).should == 'success'
    end

    it 'returns failure header class for a failed build' do
      build.stubs(:result).returns(1)
      header_result(build).should == 'failure'
    end
  end
end
