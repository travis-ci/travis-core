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
        options[:targets]
      end

      def message
        @messages ||= templates.map do |template|
          Shared::Template.new(template, data).interpolate
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

        def templates
          templates = config[:template] rescue nil
          Array(templates || DEFAULT_TEMPLATE)
        end

        def send_line(url, room_id, line)
          http.post(url) do |req|
            req.body = {
              :room_id => room_id,
              :from => 'Travis CI',
              :message => line,
              :message_format => 'text',
              :color => (build_passed? ? 'green' : 'red')
            }
          end
        end

        def parse(target)
          target =~ /(\w+)@([\w ]+)/
          ["https://api.hipchat.com/v1/rooms/message?format=json&auth_token=#{$1}", $2]
        end

        def build_passed?
          data['build']['result'] == 0
        end

        Notification::Instrument::Task::Hipchat.attach_to(self)
    end
  end
end
