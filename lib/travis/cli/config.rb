require 'thor'
require 'shellwords'
require 'fileutils'

module Travis
  module Cli
    class Config < Thor
      autoload :Keychain, 'travis/cli/config/keychain'

      include Cli

      namespace 'travis:config'

      desc 'sync', 'Sync config between keychain, app and local working directory'
      method_option :restart, :aliases => '-r', :type => :boolean, :default => true
      def sync(remote)
        @remote = remote
        store
        push
        restart if restart?
      end

      protected

        attr_reader :remote

        def app
          @app ||= begin
            app = File.basename(Dir.pwd).gsub('travis-', '')
            app = 'web' if app == 'ci'
            app
          end
        end

        def config
          @config ||= Keychain.new(app, shell).fetch
        end

        def store
          backup if backup?
          File.open(filename, 'w+') { |f| f.write(config) }
        end

        def push
          run "heroku config:add travis_config=#{Shellwords.escape(config)} -r #{remote}", :echo => "heroku config:add travis_config=... -r #{app}"
        end

        def restart
          run "heroku restart -r #{remote}"
        end

        def backup
          run 'cp #{filename} #{filename}.backup'
        end

        def restart?
          !!options['restart']
        end

        def backup?
          !!options['backup']
        end

        def filename
          "config/travis.yml"
        end
    end
  end
end

