require "travis/travis_yml_stats"

class FakeMetriks
  class Meter
    def initialize(metriks, name)
      @metriks = metriks
      @name = name
    end

    def mark
      @metriks.marked << @name
    end
  end

  attr_reader :marked

  def initialize
    @marked = []
  end

  def meter(name)
    Meter.new(self, name)
  end
end

describe Travis::TravisYmlStats do
  let(:metriks) { FakeMetriks.new }
  subject { described_class.store_stats(request, metriks) }

  let(:request) do
    stub(config: {
    }, payload: {
      "repository" => {}
    })
  end

  describe "travis_yml.language." do
    context "language: ruby" do
      before do
        request.config["language"] = "ruby"
      end

      it "marks travis_yml.language.ruby" do
        subject

        metriks.marked.should include("travis_yml.language.ruby")
      end
    end

    context "no language key" do
      it "marks travis_yml.language.empty" do
        subject
        metriks.marked.should include("travis_yml.language.empty")
      end
    end

    context "language: [ 'ruby', 'python' ]" do
      before do
        request.config["language"] = [ "ruby", "python" ]
      end

      it "marks travis_yml.language.invalid" do
        subject
        metriks.marked.should include("travis_yml.language.invalid")
      end
    end

    context "language: objective c" do
      before do
        request.config["language"] = "objective c"
      end

      it "removes the space" do
        subject
        metriks.marked.should include("travis_yml.language.objectivec")
      end
    end
  end

  describe "travis_yml.github_language." do
    context "GitHub reports Ruby" do
      before do
        request.payload["repository"]["language"] = "Ruby"
      end

      it "marks travis_yml.github_language.ruby" do
        subject
        metriks.marked.should include("travis_yml.github_language.ruby")
      end
    end

    context "GitHub reports F#" do
      before do
        request.payload["repository"]["language"] = "F#"
      end

      it "marks travis_yml.github_language.f-sharp" do
        subject
        metriks.marked.should include("travis_yml.github_language.f-sharp")
      end
    end

    context "GitHub doesn't report language" do
      before do
        request.payload["repository"]["language"] = nil
      end

      it "marks travis_yml.github_language.empty" do
        subject
        metriks.marked.should include("travis_yml.github_language.empty")
      end
    end
  end

  describe "travis_yml.ruby." do
    context "ruby: 2.1.2" do
      before do
        request.config["ruby"] = "2.1.2"
      end

      it "marks travis_yml.ruby.2.1.2" do
        subject
        metriks.marked.should include("travis_yml.ruby.2.1.2")
      end
    end

    context "ruby: [ '2.0.0', '2.1.2' ]" do
      before do
        request.config["ruby"] = %w[ 2.0.0 2.1.2 ]
      end

      it "marks travis_yml.ruby.2.0.0" do
        subject
        metriks.marked.should include("travis_yml.ruby.2.0.0")
      end

      it "marks travis_yml.ruby.2.1.2" do
        subject
        metriks.marked.should include("travis_yml.ruby.2.1.2")
      end
    end
  end

  describe "travis_yml.deploy.provider." do
    context "single provider" do
      before do
        request.config["deploy"] = { "provider" => "heroku" }
      end

      it "marks travis_yml.deploy.provider.<provider>" do
        subject
        metriks.marked.should include("travis_yml.deploy.provider.heroku")
      end
    end

    context "multiple providers" do
      before do
        request.config["deploy"] = [
          { "provider" => "heroku" },
          { "provider" => "s3" }
        ]
      end

      it "marks travis_yml.deploy.provider.<provider-1>" do
        subject
        metriks.marked.should include("travis_yml.deploy.provider.heroku")
      end

      it "marks travis_yml.deploy.provider.<provider-2>" do
        subject
        metriks.marked.should include("travis_yml.deploy.provider.s3")
      end
    end
  end

  describe "travis_yml.sudo" do
    context "build that uses sudo" do
      before do
        request.config["before_install"] = "sudo apt-get update"
      end

      it "marks travis_yml.sudo" do
        subject
        metriks.marked.should include("travis_yml.sudo")
      end
    end

    context "build that doesn't use sudo" do
      it "does not mark travis_yml.sudo" do
        subject
        metriks.marked.should_not include("travis_yml.sudo")
      end
    end
  end
end
