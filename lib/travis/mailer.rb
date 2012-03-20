require 'action_mailer'
require 'i18n'
require 'pathname'
require 'postmark-rails'

module Travis
  module Mailer
    autoload :Build, 'travis/mailer/build'

    module Helper
      autoload :Build, 'travis/mailer/helper/build'
    end

    class << self
      def setup
        mailer = ActionMailer::Base
        mailer.delivery_method   = :postmark
        mailer.postmark_settings = { :api_key => Travis.config.smtp.user_name }
        mailer.append_view_path(base_dir.join('views').to_s)

        I18n.load_path += Dir[base_dir.join('locales/**/*.yml')]
      end

      def base_dir
        Pathname.new(File.expand_path('../mailer', __FILE__))
      end
    end
  end
end
