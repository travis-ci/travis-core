module Travis
  module Addons
    module Slack
      class Task < Travis::Task
        def process
          targets.each do |target|
            if illegal_format?(target)
              Travis.logger.warn "Ignoring invalid Slack target #{target}"
            else
              send_message(target)
            end
          end
        end

        def targets
          params[:targets]
        end

        def illegal_format?(target)
          !target.match(/^[a-zA-Z0-9-]+:[a-zA-Z0-9_-]+(#.+)?$/)
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
            attachments: [{
              text: message_text,
              color: color
            }],
            icon_url: "https://travis-ci.org/images/travis-mascot-150.png"
          }

          if channel.present?
            message[:channel] = "#{channel}"
          end

          message
        end

        def message_text
          line = template_from_config || "Build <%{build_url}|#%{build_number}> (<%{compare_url}|%{commit}>) of %{repository}@%{branch} by %{author} %{result} in %{duration}"
          Util::Template.new(line, payload).interpolate
        end

        def color
          case build[:state].to_s
          when "passed"
            "good"
          when "failed"
            "danger"
          else
            "warning"
          end
        end

        def template_from_config
          config.is_a?(Hash) ? template_for(build[:state]) : nil
        end

        def config
          build[:config].try(:[], :notifications).try(:[], :slack) || {}
        end

        Instruments::Task.attach_to(self)
      end
    end
  end
end
