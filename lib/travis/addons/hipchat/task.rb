module Travis
  module Addons
    module Hipchat

      # Publishes a build notification to hipchat rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Hipchat credentials can be encrypted using the repository's ssl key.
      class Task < Travis::Task
        DEFAULT_TEMPLATE = [
          "%{repository}#%{build_number} (%{branch} - %{commit} : %{author}): the build has %{result}",
          "Change view: %{compare_url}",
          "Build details: %{build_url}"
        ]

        def targets
          params[:targets]
        end

        def message
          @messages ||= template.map { |line| Util::Template.new(line, payload).interpolate }
        end

        private

          def process
            targets.each { |target| send_lines(target, message) }
          end

          def send_lines(target, lines)
            url, room_id = parse(target)
            lines.each { |line| send_line(url, room_id, line) }
          end

          def template
            template = config[:template] rescue nil
            Array(template || DEFAULT_TEMPLATE)
          end

          def send_line(url, room_id, line)
            http.post(url) do |r|
              r.body = { room_id: room_id, message: line, color: color, from: 'Travis CI', message_format: 'text' }
            end
          end

          def parse(target)
            target =~ /^([\w]+)@([\w ]+)$/
            ["https://api.hipchat.com/v1/rooms/message?format=json&auth_token=#{$1}", $2]
          end

          def color
            build[:result] == 0 ? 'green' : 'red'
          end

          def config
            build[:config][:notifications][:hipchat] rescue {}
          end

          Instruments::Task.attach_to(self)
      end
    end
  end
end

