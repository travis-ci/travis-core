# backports 1.9 style string interpolation. can be removed once hub runs in 1.9 mode
require 'i18n/core_ext/string/interpolate'

module Travis
  class Task
    # Publishes a build notification to campfire rooms as defined in the
    # configuration (`.travis.yml`).
    #
    # Campfire credentials are encrypted using the repository's ssl key.
    class Campfire < Task
      DEFAULT_TEMPLATE = [
        "[travis-ci] %{repository}#%{build_number} (%{branch} - %{commit} : %{author}): the build has %{result}",
        "[travis-ci] Change view: %{compare_url}",
        "[travis-ci] Build details: %{build_url}"
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
          url, token = parse(target)
          http.basic_auth(token, 'X')
          lines.each { |line| send_line(url, line) }
        end

        def templates
          templates = config[:template] rescue nil
          Array(templates || DEFAULT_TEMPLATE)
        end

        def send_line(url, line)
          http.post(url) do |req|
            req.body = MultiJson.encode({ :message => { :body => line } })
            req.headers['Content-Type'] = 'application/json'
          end
        end

        def parse(target)
          target =~ /([\w-]+):([\w-]+)@(\d+)/
          ["https://#{$1}.campfirenow.com/room/#{$3}/speak.json", $2]
        end

        def config
          data['build']['config']['notifications'][:campfire] rescue {}
        end
        Notification::Instrument::Task::Campfire.attach_to(self)
    end
  end
end
