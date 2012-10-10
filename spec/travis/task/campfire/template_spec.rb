require 'spec_helper'

describe Travis::Task::Campfire::Template do
  include Travis::Testing::Stubs


  let(:data)     { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:template) {
    template_string = %w(repository build_number branch commit author message compare_url build_url result).map do |name|
    "#{name}=%{#{name}}" 
    end.join(' ')
    Travis::Task::Campfire::Template.new(template_string, data) 
  }

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