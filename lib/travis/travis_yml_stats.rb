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
      Metriks.meter("travis_yml.language.#{config["language"]}").mark
      Metriks.meter("travis_yml.github_language.#{payload["language"]}").mark
    end

    def config
      request.config
    end

    def payload
      request.payload
    end
  end
end
