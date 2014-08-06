require "metriks"

module Travis
  class TravisYmlStats
    def self.store_stats(request)
      new(request).store_stats
    end

    def initialize(request)
      @request = request
    end

    def store_stats
      store_language
    end

    private

    attr_reader :request

    def store_language
      mark_metric "travis_yml.language.#{travis_yml_language}"
      mark_metric "travis_yml.github_language.#{github_language}"
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
      Metriks.meter(normalized_name).mark
    end
  end
end
