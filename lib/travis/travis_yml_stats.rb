require "metriks"

module Travis
  class TravisYmlStats
    LANGUAGE_VERSION_KEYS = %w[
      ruby rvm
      python
      otp_release
      go
      jdk
      ghc
      jdk
      node_js
      perl
      php
      python
      rvm
      scala
    ]

    def self.store_stats(request, metriks=Metriks)
      new(request, metriks).store_stats
    end

    def initialize(request, metriks=Metriks)
      @request = request
      @metriks = metriks
    end

    def store_stats
      store_language
      store_language_version
    end

    private

    attr_reader :request

    def store_language
      mark_metric "travis_yml.language.#{travis_yml_language}"
      mark_metric "travis_yml.github_language.#{github_language}"
    end

    def store_language_version
      LANGUAGE_VERSION_KEYS.each do |key|
        if config.key?(key)
          case config[key]
          when String
            mark_metric "travis_yml.#{key}.#{config[key]}"
          when Array
            config[key].each do |version|
              mark_metric "travis_yml.#{key}.#{version}"
            end
          else
            mark_metric "travis_yml.#{key}.invalid"
          end
        end
      end
    end

    def config
      request.config
    end

    def payload
      request.payload
    end

    def travis_yml_language
      language = config["language"]
      case language
      when String
        normalize_string language
      when nil
        "empty"
      else
        "invalid"
      end
    end

    def github_language
      language = payload.fetch("repository", {})["language"]
      case language
      when String
        normalize_string language
      when nil
        "empty"
      when Array
        normalize_string language.first
      else
        "invalid"
      end
    end

    def normalize_string(str)
      str.downcase.gsub("#", "-sharp").gsub(/[^A-Za-z0-9.:\-_]/, "")
    end

    def mark_metric(metric_name)
      normalized_name = metric_name.gsub(/[^A-Za-z0-9.:\-_]/, "")
      @metriks.meter(normalized_name).mark
    end
  end
end
