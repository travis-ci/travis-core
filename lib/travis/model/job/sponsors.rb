require 'active_support/concern'

class Job
  module Sponsors
    class << self
      def sponsors
        @@sponsors ||= YAML.load_file('./config/sponsors.yml') rescue {}
      end
    end

    def prepend_sponsor
      log.prepend(%(Sponsored by <a href="#{sponsor.url}">#{sponsor.name}</a>\n))
    end

    # TODO this overwrites the activerecord attribute which currently is not populated from the actual worker
    def worker
      (log.content || '').split("\n").first =~ /Using worker: ([^:]+):/ and $1
    end

    def sponsor
      Hashr.new(Sponsors.sponsors[worker] || {})
    end
  end
end

