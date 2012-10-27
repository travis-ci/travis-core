module Travis
  module Addons
    module Campfire

      # Publishes a build notification to campfire rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Campfire credentials are encrypted using the repository's ssl key.
      class Task < Travis::Task
        DEFAULT_TEMPLATE = [
          "[travis-ci] %{repository}#%{build_number} (%{branch} - %{commit} : %{author}): the build has %{result}",
          "[travis-ci] Change view: %{compare_url}",
          "[travis-ci] Build details: %{build_url}"
        ]

        def targets
          params[:targets]
        end

        def message
          @message ||= template.map { |line| Util::Template.new(line, payload).interpolate }
        end

        private

          def process
            targets.each { |target| send_message(target, message) }
          end

          def send_message(target, lines)
            url, token = parse(target)
            http.basic_auth(token, 'X')
            lines.each { |line| send_line(url, line) }
          end

          def send_line(url, line)
            http.post(url, { message: { body: line } }, 'Content-Type' => 'application/json')
          end

          def template
            Array(config[:template] || DEFAULT_TEMPLATE)
          end

          def parse(target)
            target =~ /([\w-]+):([\w-]+)@(\d+)/
            ["https://#{$1}.campfirenow.com/room/#{$3}/speak.json", $2]
          end

          def config
            build[:config][:notifications][:campfire] rescue {}
          end

          Instruments::Task.attach_to(self)
      end
    end
  end
end
