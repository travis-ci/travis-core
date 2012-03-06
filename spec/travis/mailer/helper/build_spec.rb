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

  describe 'header_background_style' do
    it 'returns success background image style for successful build' do
      header_background_style(successful_build).should == <<-style.strip
        style="background: url('https://secure.travis-ci.org/images/mailer/success-header-bg.png') no-repeat scroll 0 0 transparent; padding: 8px 15px;"
      style
    end

    it 'returns failure background image style for failed build' do
      header_background_style(failed_build).should == <<-style.strip
        style="background: url('https://secure.travis-ci.org/images/mailer/failure-header-bg.png') no-repeat scroll 0 0 transparent; padding: 8px 15px;"
      style
    end
  end
end

