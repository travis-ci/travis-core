require 'spec_helper'

describe Travis::Task::Irc::Template do
  include Travis::Testing::Stubs

  TEMPLATE = %w(repository build_number branch commit author commit_message message compare_url build_url).map do |name|
    "#{name}=%{#{name}}"
  end.join(' ')

  let(:data)     { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:template) { Travis::Task::Irc::Template.new(TEMPLATE, data) }

  before do
    # TODO remove this db dependency
    Repository.stubs(:find).returns(repository)
    Travis::Features.stubs(:active?).with(:short_urls, repository).returns(true)
    Url.stubs(:shorten).returns(url)
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

    it 'replaces the commit message' do
      result.should =~ /commit_message=the commit message/
    end

    it 'replaces the message' do
      result.should =~ /message=The build passed./
    end

    describe 'with shortening enabled' do
      it 'replaces the build url in short form' do
        result.should =~ %r(build_url=http://trvs.io/)
      end

      it 'replaces the compare url in short form' do
        result.should =~ %r(compare_url=http://trvs.io/)
      end
    end

    describe 'with shortening disabled' do
      before do
        Travis::Features.stubs(:active?).with(:short_urls, repository).returns(false)
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

