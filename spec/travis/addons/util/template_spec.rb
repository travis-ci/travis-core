require 'spec_helper'

describe Travis::Addons::Util::Template do
  include Travis::Testing::Stubs

  VAR_NAMES = %w(repository build_number branch commit author message compare_url build_url result)
  TEMPLATE  = VAR_NAMES.map { |name| "#{name}=%{#{name}}" }.join(' ')

  let(:data)     { Travis::Api.data(build, for: 'event', version: 'v0') }
  let(:template) { Travis::Addons::Util::Template.new(TEMPLATE.dup, data) }

  describe 'interpolation' do
    let(:result) { template.interpolate }

    it 'replaces the repository' do
      result.should =~ %r(repository=svenfuchs/minimal)
    end

    it 'replaces the build_number' do
      result.should =~ /build_number=#{build.number}/
    end

    it 'replaces the branch' do
      result.should =~ /branch=master/
    end

    it 'replaces the author' do
      result.should =~ /author=Sven Fuchs/
    end

    it 'replaces the message' do
      result.should =~ /message=The build passed./
    end
  end
end
