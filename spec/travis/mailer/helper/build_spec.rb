require 'spec_helper'
require 'support/active_record'

describe Travis::Mailer::Helper::Build do
  include Travis::Mailer::Helper::Build

  let(:build) { Factory(:successful_build) }

  it '#title returns title for the build' do
    title(build).should == 'Build Update for svenfuchs/successful_build'
  end

  describe 'gradient_styles' do
    let(:build)  { Factory.build(:build, :status => status) }
    let(:styles) { gradient_styles(build) }

    describe 'given a successful build' do
      let(:status) { 0 }

      it 'returns gradiant styles' do
        styles.should =~ /background: .*-moz-linear-gradient.*-webkit-gradient.*-webkit-linear-gradient.*linear-gradient/
      end

      it 'returns green styles for a successful build' do
        Travis::Mailer::Helper::Build::GRADIENTS[:success].each do |color|
          styles.should include(color)
        end
      end
    end

    describe 'given a failed build' do
      let(:status) { 1 }

      it 'returns gradiant styles' do
        styles.should =~ /background: .*-moz-linear-gradient.*-webkit-gradient.*-webkit-linear-gradient.*linear-gradient/
      end

      it 'returns red styles for a failed build' do
        Travis::Mailer::Helper::Build::GRADIENTS[:failure].each do |color|
          styles.should include(color)
        end
      end
    end
  end
end

