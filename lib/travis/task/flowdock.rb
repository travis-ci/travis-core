# backports 1.9 style string interpolation. can be removed once hub runs in 1.9 mode
require 'i18n/core_ext/string/interpolate'

module Travis
  class Task
    # Publishes a build notification to flowdock rooms as defined in the
    # configuration (`.travis.yml`).
    #
    # Flowdock credentials are encrypted using the repository's ssl key.
    class Flowdock < Task
      TEMPLATE = <<-EOT
<ul>
<li><code><a href="https://github.com/%{slug}">%{slug}</a></code> build #%{number} has %{result}!</li>
<li>Branch: <code>%{branch}</code></li>
<li>Latest commit: <code><a href="%{sha_url}">%{sha}</a></code> by <a href="mailto:%{author_email}">%{author}</a></li>
<li>Change view: %{compare_url}</li>
<li>Build details: %{build_url}</li>
</ul>
EOT

      def targets
        options[:targets]
      end

      def message
        @message ||= begin
          args = {
            :slug   => data['repository']['slug'],
            :number => data['build']['number'],
            :branch => data['commit']['branch'],
            :sha    => data['commit']['sha'][0..6],
            :sha_url => "https://github.com/#{data['repository']['slug']}/commit/#{data['commit']['sha']}",
            :author => data['commit']['author_name'],
            :author_email => data['commit']['author_email'],
            :result => build_result,
            :compare_url => data['commit']['compare_url'],
            :build_url => build_url
          }
          TEMPLATE % args
        end
      end

      private

        def process
          targets.each { |target| send_message(target) }
        end

        def send_message(target)
          url = team_inbox_url_for(target)
          http.post(url) do |req|
            req.body = MultiJson.encode(flowdock_payload)
            req.headers['Content-Type'] = 'application/json'
          end
        end

        def build_url
          "#{Travis.config.http_host}/#{data['repository']['slug']}/builds/#{data['build']['id']}"
        end

        def build_passed?
          data['build']['result'] == 0
        end

        def build_result
          build_passed? ? 'passed' : 'failed'
        end

        def build_tag
          build_passed? ? 'ok' : 'fail'
        end

        def team_inbox_url_for(target)
          "https://api.flowdock.com/v1/messages/team_inbox/#{target}"
        end

        def flowdock_subject
          slug = data['repository']['slug']
          number = data['build']['number']
          "#{slug} build ##{number} has #{build_result}!"
        end

        def flowdock_payload
          {
            :source       => 'Travis',
            :from_address => "build+#{build_tag}@flowdock.com",
            :subject      => flowdock_subject,
            :content      => message,
            :from_name    => 'CI',
            :project      => 'Build Status',
            :format       => 'html',
            :tags         => ["ci", build_tag],
            :link         => build_url
          }
        end

        Notification::Instrument::Task::Flowdock.attach_to(self)
    end
  end
end
