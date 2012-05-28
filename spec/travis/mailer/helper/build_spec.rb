require 'spec_helper'
require 'support/active_record'

describe Travis::Mailer::Helper::Build do
  include Travis::Mailer::Helper::Build
  include Support::ActiveRecord

  let(:build) { Factory(:running_build) }
  let(:repository) { build.repository }

  let(:successful_build) { Factory(:build, :result => 0) }
  let(:failed_build)     { Factory(:build, :result => 1) }

  it '#title returns title for the build' do
    title(repository).should == 'Build Update for svenfuchs/running_build'
  end

  describe 'header_result' do
    it 'returns failure header class for a failed build' do
      header_result(failed_build).should == 'failure'
    end

    it 'returns success header class for a successful build' do
      header_result(successful_build).should == 'success'
    end
  end
end

