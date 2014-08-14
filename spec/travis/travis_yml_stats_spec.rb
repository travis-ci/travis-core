require "spec_helper"
require "travis/travis_yml_stats"

describe Travis::TravisYmlStats do
  let(:publisher) { mock("keen-publisher") }
  subject { described_class.store_stats(request, publisher) }

  let(:request) do
    stub({
      config: {},
      payload: {
        "repository" => {}
      },
      repository_id: 123,
    })
  end

  def event_should_contain(opts)
    publisher.expects(:perform_async).with(has_entries(opts))
  end

  describe ".travis.yml language key" do
    context "when `language: ruby'" do
      before do
        request.config["language"] = "ruby"
      end

      it "sets the language key to 'ruby'" do
        event_should_contain language: "ruby"

        subject
      end
    end

    context "when not specified" do
      it "sets the language key to nil" do
        event_should_contain language: nil

        subject
      end
    end

    context "when `language: [ 'ruby', 'python' ]'" do
      before do
        request.config["language"] = [ "ruby", "python" ]
      end

      it "sets the language key to 'invalid'" do
        event_should_contain language: "invalid"

        subject
      end
    end

    context "when `language: objective c'" do
      before do
        request.config["language"] = "objective c"
      end

      it "retains the space" do
        event_should_contain language: "objective c"

        subject
      end
    end
  end

  describe "repository language reported by GitHub" do
    context "Ruby" do
      before do
        request.payload["repository"]["language"] = "Ruby"
      end

      it "sets the github_language key to 'Ruby'" do
        event_should_contain github_language: "Ruby"

        subject
      end
    end

    context "F#" do
      before do
        request.payload["repository"]["language"] = "F#"
      end

      it "sets the github_language key to 'F#'" do
        event_should_contain github_language: "F#"

        subject
      end
    end

    context "no language reported" do
      before do
        request.payload["repository"]["language"] = nil
      end

      it "sets the github_language key to nil" do
        event_should_contain github_language: nil

        subject
      end
    end
  end

  describe ".travis.yml ruby key" do
    context "when `ruby: 2.1.2'" do
      before do
        request.config["ruby"] = "2.1.2"
      end

      it "sets the language_version.ruby key to ['2.1.2']" do
        event_should_contain language_version: { ruby: ["2.1.2"] }

        subject
      end
    end

    context "when `ruby: [ '2.1.2', '2.0.0' ]'" do
      before do
        request.config["ruby"] = %w[ 2.1.2 2.0.0 ]
      end

      it "sets the language_version.ruby key to ['2.0.0', '2.1.2']" do
        event_should_contain language_version: { ruby: %w[2.0.0 2.1.2] }

        subject
      end
    end
  end

  describe "sudo being used in a command" do
    context "sudo is used in a command" do
      before do
        request.config["before_install"] = "sudo apt-get update"
      end

      it "sets the uses_sudo key to true" do
        event_should_contain uses_sudo: true

        subject
      end
    end

    context "sudo is not used in any commands" do
      it "sets the uses_sudo key to false" do
        event_should_contain uses_sudo: false

        subject
      end
    end
  end

  describe "apt-get being used in a command" do
    context "apt-get is used in a command" do
      before do
        request.config["before_install"] = "sudo apt-get update"
      end

      it "sets the uses_apt_get key to true" do
        event_should_contain uses_apt_get: true

        subject
      end
    end

    context "apt-get is not used in any commands" do
      it "sets the uses_apt_get key to false" do
        event_should_contain uses_apt_get: false

        subject
      end
    end
  end
end
