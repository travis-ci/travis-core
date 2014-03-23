module Travis
  module Addons
    module Sqwiggle

      # Publishes a build notification to a Sqwiggle stream as defined in the
      # configuration (`.travis.yml`).
      #
      class Task < Travis::Task
        DEFAULT_TEMPLATE = %Q[
          %{repository} - build number: %{build_number} (%{branch} - %{commit} : %{author}) -
          <a href="%{build_url}" target="_blank">build</a> has
          <strong>%{result}</strong>
        ]

        def targets
          params[:targets]
        end

        def message
          @message ||= Util::Template.new(template, payload).interpolate.squish
        end

        private

        def template
          template_for(build[:state]) || DEFAULT_TEMPLATE
        end

        def process
          targets.each do |target|
            send_message(*parse(target))
          end
        end

        def send_message(url, room_id)
          http.post(url) do |r|
            r.body = MultiJson.encode(sqwiggle_payload(room_id))
            r.headers['Content-Type'] = 'application/json'
          end
        end

        def sqwiggle_payload(room_id)
          {
            text: message,
            format: 'html',
            color: color,
            parse: false,
            room_id: room_id.to_i
          }
        end

        def parse(target)
          target =~ /^([\w]+)@([\S ]+)$/
          ["https://api.sqwiggle.com/messages?auth_token=#{$1}", $2]
        end

        def color
          {
            "passed" => "green",
            "failed" => "red",
            "errored" => "gray",
            "canceled" => "gray",
          }.fetch(build[:state], "yellow")
        end

        def message_format
          (config[:format] rescue nil) || 'text'
        end

        def config
          build[:config][:notifications][:sqwiggle] rescue {}
        end

        Instruments::Task.attach_to(self)
      end
    end
  end
end
