module Travis
  module Addons
    module Slack
      class Task < Travis::Task
        def process
          targets.each do |target|
            send_message(target)
          end
        end

        def targets
          params[:targets]
        end

        def send_message(target)
          url, channel = parse(target)
          http.post(url) do |request|
            request.body = MultiJson.encode(message(channel))
          end
        end

        def parse(target)
          account, appendix = target.split(":")
          token, channel = appendix.split("#")
          channel = "##{channel}"
          url = "https://#{account}.slack.com/services/hooks/incoming-webhook?token=#{token}"
          [url, channel]
        end

        def message(channel)
          {
            channel: "#{channel}",
            text: message_text
          }
        end

        def message_text
          line = "[travis-ci] Build #%{build_number} (<%{compare_url}|Changes>) by %{author} <%{build_url}|%{result}>"
          Util::Template.new(line, payload).interpolate
        end

        Instruments::Task.attach_to(self)
      end
    end
  end
end
