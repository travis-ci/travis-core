require 'action_mailer'
require 'i18n'

module Travis
  module Addons
    module Email
      autoload :EventHandler,   'travis/addons/email/event_handler'
      autoload :Instruments,    'travis/addons/email/instruments'
      autoload :Task,           'travis/addons/email/task'

      module Mailer
        autoload :Build,        'travis/addons/email/mailer/build'
        autoload :Helpers,      'travis/addons/email/mailer/helpers'
      end

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
