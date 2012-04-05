require 'action_mailer'

module Travis
  module Mailer
    class Build < ActionMailer::Base
      helper Helper::Build

      def finished_email(build, recipients)
        @build  = build
        @commit = build.commit
        mail(:from => from, :to => recipients, :subject => subject, :template_path => 'build')
      end

      private

        def subject
          "[#{@build.status_message}] #{@build.repository.slug}##{@build.number} (#{@commit.branch} - #{@commit.commit[0, 7]})"
        end

        def from
          Travis.config.email.from || "notifications@#{Travis.config.host}"
        end
    end
  end
end
