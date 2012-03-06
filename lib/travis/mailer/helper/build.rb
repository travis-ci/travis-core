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

        def header_status(build)
          build.passed? ? 'success' : 'failure'
        end

        def header_background_style(build)
          image_url = "https://secure.travis-ci.org/images/mailer/#{header_status(build)}-header-bg.png"
          %(style="background: url('#{image_url}') no-repeat scroll 0 0 transparent; padding: 8px 15px;")
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
      end
    end
  end
end
