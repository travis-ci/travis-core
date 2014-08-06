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
end
