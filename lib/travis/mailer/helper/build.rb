require 'base64'
require 'rack'

module Travis
  module Mailer
    module Helper
      module Build
        def sponsors
          package  = [:platinum, :platinum, :gold].shuffle.first
          count    = package == :platinum ? 1 : 2
          sponsors = Travis.config.sponsors[package] || []
          sponsors.shuffle[0, count].map do |sponsor|
            Hashr.new(sponsor.merge(:package => package))
          end
        end

        GRADIENTS = {
          :success => %w(#0ecf0b #0bbd0b #08ae0d #0c901d),
          :failure => %w(#f76e69 #f4564e #f64130 #e93a13)
        }

        def gradient_styles(build)
          colors = GRADIENTS[build.passed? ? :success : :failure]
          styles = <<-styles.gsub(/(^|\n)\s*/m, '')
            padding: 8px 15px;
            background: #{colors[3]};
            background: -moz-linear-gradient(top, #{colors[0]} 0%, #{colors[1]} 50%, #{colors[2]} 51%, #{colors[3]} 100%);
            background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#{colors[0]}), color-stop(50%,#{colors[1]}), color-stop(51%,#{colors[2]}), color-stop(100%,#{colors[3]}));
            background: -webkit-linear-gradient(top, #{colors[0]} 0%,#{colors[1]} 50%,#{colors[2]} 51%,#{colors[3]} 100%);
            background: linear-gradient(top, #{colors[0]} 0%,#{colors[1]} 50%,#{colors[2]} 51%,#{colors[3]} 100%);
          styles
        end

        def encode_image(path)
          path = File.expand_path("../../views/#{path}", __FILE__)
          type = Rack::Mime.mime_type(File.extname(path))
          data = Base64.encode64(File.read(path)) if File.exists?(path)
          "data:#{type};base64,#{data}"
        end

        def repository_build_url(options)
          [Travis.config.host, options[:slug], 'builds', options[:id]].join('/')
        end

        def title(build)
          "Build Update for #{build.repository.slug}"
        end

        # 1 hour, 10 minutes, and 15 seconds
        # 1 hour, 0 minutes, and 5 seconds
        # 1 minutes and 1 second
        # 15 seconds
        def duration_in_words(started_at, finished_at)
          # difference in seconds
          diff = (finished_at - started_at).to_i

          hours   = hours_part(diff)
          minutes = minutes_part(diff)
          seconds = seconds_part(diff)

          time_pieces = []

          time_pieces << I18n.t(:'datetime.distance_in_words.hours_exact',   :count => hours)   if hours > 0
          time_pieces << I18n.t(:'datetime.distance_in_words.minutes_exact', :count => minutes) if hours > 0 || minutes > 0
          time_pieces << I18n.t(:'datetime.distance_in_words.seconds_exact', :count => seconds)

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

        def notes(build, format)
          rules = Job::Tagging.rules
          messages = build.matrix_uniq_tags.map do |tag|
             if message = rules[rules.index {|rule| rule["tag"] == tag}]["message"]
               jobs_list = build.matrix.map do |job|
                 job.job_id if job.tags =~ /#{tag}/
               end
               jobs_list = jobs_list.compact.to_sentence
               formated_note(format, message, jobs_list)
             end
          end

          "\n" + messages.join("\n")
        end

        def formated_note(format, message, jobs_list)
          case format
            when "text" then "* #{message} (#{jobs_list}) <br />"
            when "html" then "<li>#{message} (#{jobs_list})</li>"
          end
        end
      end
    end
  end
end
