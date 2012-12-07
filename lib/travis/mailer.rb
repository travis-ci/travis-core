require 'action_mailer'
require 'i18n'
require 'postmark-rails'

module Travis
  module Mailer
    class << self
      def setup
        mailer = ActionMailer::Base
        mailer.delivery_method   = :postmark
        mailer.postmark_settings = { :api_key => Travis.config.smtp.user_name }
      end
    end
  end
end
