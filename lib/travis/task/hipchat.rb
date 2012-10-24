# backports 1.9 style string interpolation. can be removed once hub runs in 1.9 mode
require 'i18n/core_ext/string/interpolate'

module Travis
  class Task
    # Publishes a build notification to hipchat rooms as defined in the
    # configuration (`.travis.yml`).
    #
    # Hipchat credentials can be encrypted using the repository's ssl key.
    class Hipchat < Task
      DEFAULT_TEMPLATE = [
        "%{repository}#%{build_number} (%{branch} - %{commit} : %{author}): the build has %{result}",
        "Change view: %{compare_url}",
        "Build details: %{build_url}"
      ]

      def targets
        params[:targets]
      end

      def message
        @messages ||= template.map do |line|
          Shared::Template.new(line, payload).interpolate
        end
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
          Array(config[:template] || DEFAULT_TEMPLATE)
        end

        def send_line(url, room_id, line)
          body = {
            room_id: room_id,
            from: 'Travis CI',
            message: line,
            message_format: 'text',
            color: color
          }
          http.post(url, body)
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

        Notification::Instrument::Task::Hipchat.attach_to(self)
    end
  end
end
