require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::Handler::Irc::Template do
  include Support::ActiveRecord

  TEMPLATE = %w(repository build_number branch commit author message compare_url build_url).map do |name|
    "#{name}=%{#{name}}"
  end.join(' ')

  let(:build)    { Factory(:build, :state => 'finished', :previous_result => nil, :result => 0)}
  let(:user)     { Factory(:user)}
  let(:data)     { Travis::Api.data(build, :for => 'notifications', :version => 'v2') }
  let(:template) { Travis::Notifications::Handler::Irc::Template.new(TEMPLATE, data) }

  before do
    Travis::Features.start
  end

  describe 'interpolation' do
    let(:result) { template.interpolate }

    it 'replaces the repository' do
      result.should =~ %r(repository=svenfuchs/minimal)
    end

    it 'replaces the build number' do
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

    describe 'with shortening enabled' do
      before do
        Travis::Features.activate_user(:short_urls, build.repository.owner)
      end

      it 'replaces the build url in short form' do
        result.should =~ %r(build_url=http://trvs.io/)
      end

      it 'replaces the compare url in short form' do
        result.should =~ %r(compare_url=http://trvs.io/)
      end
    end

    describe 'with shortening disabled' do
      before do
        Travis::Features.deactivate_user(:short_urls, build.repository.owner)
      end

      it 'replaces the compare url the full form' do
        result.should =~ %r(compare_url=https://github.com/svenfuchs/minimal/compare/master...develop)
      end

      it 'replaces the build url the full form' do
        result.should =~ %r(build_url=http://travis-ci.org/svenfuchs/minimal/builds)
      end
    end
  end
end
