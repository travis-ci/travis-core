require 'spec_helper'
require 'travis/notifications/handler/template'
require 'support/active_record'

describe Travis::Notifications::Handler::Template do
  let(:build) { Factory(:build)}
  let(:template_string) {
    template =<<TEMPLATE
author=%{author}
build_url=%{build_url}
compare_url=%{compare_url}
TEMPLATE
  }
  let(:template) {
    Travis::Notifications::Handler::Template.new(template_string, build)
  }
  let(:user) { Factory(:user)}
  before do
    Travis::Features.start
    Travis::Features.activate_user(:short_urls, user)
  end

  after do
    user.destroy
  end

  describe "interpolating" do
    let(:interpolated) {template.interpolate}

    it "should replace the author" do
      interpolated.should =~ /author=Sven Fuchs/
    end

    it "should replace the build url" do
      interpolated.should =~ %r{build_url=http://trvs.io/}
    end

    it "should replace the compare url" do
      interpolated.should =~ %r{compare_url=http://trvs.io/}
    end

    describe "with short urls disabled"
  end

  describe "basic attributes" do
    it "should return the branch from the commit" do
      template.branch.should == 'master'
    end

    it "should return the author" do
      template.author.should == 'Sven Fuchs'
    end

    it "should return the status message" do
      template.message.should == "The build is pending."
    end

    it "should return the repository url" do
      template.repository_url.should == "svenfuchs/minimal"
    end

    it "should return the commit's hash in shortened form" do
      template.commit.should == "62aae5f"
    end

    it "should return a compare url" do
      template.compare_url.should =~ %r{http://trvs.io/}
    end

    it "should return a build url" do
      template.build_url.should =~ %r{http://trvs.io/}
    end

    describe "with shortening disabled" do
      before do
        Travis::Features.deactivate_user(:short_urls, build.repository.owner)
      end

      it "should return the full compare url" do
        template.compare_url.should =~ %r{https://github.com/svenfuchs/minimal/compare/master...develop}
      end
      
      it "should return the full build url" do
        template.build_url.should =~ %r{travis-ci.org/svenfuchs/minimal/builds}
      end
    end
  end
end
