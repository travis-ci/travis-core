require 'base64'
require 'rack'
require 'time'

module Travis
  module Mailer
    module Helper
      module Build
        def sponsors
          package  = [:platinum, :platinum, :gold].shuffle.first
          count    = package == :platinum ? 1 : 2
          sponsors = Travis.config.sponsors[package] || []
          sponsors.shuffle[0, count].map do |sponsor|
            Hashr.new(sponsor.merge(package: package))
          end
        end

        def header_result(build)
          build.result == 0 ? 'success' : 'failure'
        end

        def encode_image(path)
          path = File.expand_path("../../views/#{path}", __FILE__)
          type = Rack::Mime.mime_type(File.extname(path))
          data = Base64.encode64(File.read(path)) if File.exists?(path)
          "data:#{type};base64,#{data}"
        end

        def repository_build_url(options)
          [Travis.config.http_host, options[:slug], 'builds', options[:id]].join('/')
        end

        def title(repository)
          "Build Update for #{repository.slug}"
        end

        # 1 hour, 10 minutes, and 15 seconds
        # 1 hour, 0 minutes, and 5 seconds
        # 1 minutes and 1 second
        # 15 seconds
        def duration_in_words(started_at, finished_at)
          started_at  = Time.parse(started_at)  if started_at.is_a?(String)
          finished_at = Time.parse(finished_at) if finished_at.is_a?(String)

          # difference in seconds
          diff = (finished_at - started_at).to_i

          hours   = hours_part(diff)
          minutes = minutes_part(diff)
          seconds = seconds_part(diff)

          time_pieces = []

          time_pieces << I18n.t(:'datetime.distance_in_words.hours_exact',   count: hours)   if hours > 0
          time_pieces << I18n.t(:'datetime.distance_in_words.minutes_exact', count: minutes) if hours > 0 || minutes > 0
          time_pieces << I18n.t(:'datetime.distance_in_words.seconds_exact', count: seconds)

          time_pieces.to_sentence
        end

        ONE_HOUR = 3600
        ONE_MINUTE = 60

        def hours_part(diff)
          diff / ONE_HOUR
        end

        def minutes_part(diff)
          (diff % ONE_HOUR) / ONE_MINUTE
        end

        def seconds_part(diff)
          diff % ONE_MINUTE
        end

        def notes_for(jobs, format)
          tags_for(jobs).map do |tag|
            rule = rule_for(tag)
            rule.symbolize_keys.merge(jobs: numbers_for(jobs, tag)) if rule
          end.compact
        end

        def tags_for(jobs)
          jobs.map(&:tags).join(',').split(',').uniq
        end

        def rule_for(tag)
          Job::Tagging.rules.detect { |rule| rule['tag'] == tag }
        end

        def numbers_for(jobs, tag)
          jobs.map { |job| job.number if job.tags.to_s.include?(tag) }.compact
        end

        # def formated_note(format, message, numbers)
        #   case format
        #     when "text" then "* #{message} (#{numbers}) <br />"
        #     when "html" then "<li>#{message} (#{numbers})</li>"
        #   end
        # end
      end
    end
  end
end
