require 'action_mailer'

module Travis
  module Mailer
    class Build < ActionMailer::Base
      include ::Build::Messages

      helper Helper::Build, ::Build::Messages

      attr_reader :build, :commit, :repository, :jobs

      def finished_email(data, recipients)
        data = data.deep_symbolize_keys

        @build      = Hashr.new(data[:build])
        @repository = Hashr.new(data[:repository])
        @commit     = Hashr.new(data[:commit])
        @jobs       = data[:jobs].map { |job| Hashr.new(job) }
        @broadcast  = Broadcast.by_repo(repository[:id]).first

        mail(from: from, to: recipients, subject: subject, template_path: 'build')
      end

      private

        def subject
          "[#{result_message(build)}] #{repository.slug}##{build.number} (#{commit.branch} - #{commit.sha[0..6]})"
        end

        def from
          Travis.config.email.from || "notifications@#{Travis.config.host}"
        end
    end
  end
end
