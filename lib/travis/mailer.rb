require 'action_mailer'
require 'i18n'

module Travis
  module Mailer
    class << self
      def setup
        mailer = ActionMailer::Base
        mailer.delivery_method = :smtp
        mailer.smtp_settings = Travis.config.smtp
      end
    end
  end
end
