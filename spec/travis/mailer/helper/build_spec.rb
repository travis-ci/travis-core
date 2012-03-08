require 'spec_helper'
require 'support/active_record'

describe Travis::Mailer::Helper::Build do
  include Travis::Mailer::Helper::Build

  let(:build) { Factory(:running_build) }

  let(:successful_build) { Factory(:build, :status => 0) }
  let(:failed_build)     { Factory(:build, :status => 1) }

  it '#title returns title for the build' do
    title(build).should == 'Build Update for svenfuchs/running_build'
  end

  describe 'header_status' do
    it 'returns failure header class for a failed build' do
      header_status(failed_build).should == 'failure'
    end

    it 'returns success header class for a successful build' do
      header_status(successful_build).should == 'success'
    end
  end
end

