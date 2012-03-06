require 'active_support/concern'

class Job

  # Provides an `add_tags` method which will match regular expressions
  # (defined in `tagging/tagging.yml`) against both the configuration and
  # log and add the given tags to the Job.
  #
  # This is supposed to make it easy to tag jobs automatically based
  # on recurring log patterns (e.g. add the tag "gemfile-misses-rake") and
  # then later use these tags to provide guidance to users or simply make
  # it easier for the community to find particular jobs. E.g. a note
  # "Please add rake to your Gemfile and find addtional info here ..."
  # could be added to build notification emails.
  module Tagging
    class << self
      def rules
        @@rules ||= YAML.load_file(File.join("../travis-ci", "config", "tagging.yml")) rescue []
      end
    end

    def add_tags
      subject = log.content.to_s + config.to_s
      tags = Tagging.rules.inject([]) do |result, rule|
        result << rule['tag'] if subject =~ /#{rule['pattern']}/
        result
      end
      self.tags = tags.uniq.join(',')
    end
  end
end
