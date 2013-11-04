require 'action_mailer'
require 'i18n'

module Travis
  module Addons
    module Email
      module Mailer
        require 'travis/addons/email/mailer/helpers'
        require 'travis/addons/email/mailer/build'
      end

      require 'travis/addons/email/instruments'
      require 'travis/addons/email/event_handler'
      require 'travis/addons/email/task'

      class << self
        def setup
          Travis::Mailer.setup
          ActionMailer::Base.append_view_path("#{base_dir}/views")
          I18n.load_path += Dir["#{base_dir}/locales/**/*.yml"]
        end

        def base_dir
          File.expand_path('../email/mailer', __FILE__)
        end
      end
    end
  end
end
