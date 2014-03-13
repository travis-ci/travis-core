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
          if channel.present?
            channel = "##{channel}"
          end
          url = "https://#{account}.slack.com/services/hooks/travis?token=#{token}"
          [url, channel]
        end

        def message(channel)
          message = {
            text: message_text
          }

          if channel.present?
            message[:channel] = "#{channel}"
          end

          add_custom_image(message)

          message
        end

        def message_text
          line = "[travis-ci] Build #%{build_number} (<%{compare_url}|%{commit}>) of %{repository}@%{branch} by %{author} <%{build_url}|%{result}> in %{duration}"
          Util::Template.new(line, payload).interpolate
        end

        def add_custom_image(message)
          image = case payload[:build][:state].to_s
                  when 'passed'
                    'mascot-passed.png'
                  when 'failed'
                    'mascot-failed.png'
                  end
          message[:icon_url] = "http://paperplanes-assets.s3.amazonaws.com/#{image}"
        end

        Instruments::Task.attach_to(self)
      end
    end
  end
end
