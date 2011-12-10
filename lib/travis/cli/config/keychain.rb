module Travis
  module Cli
    class Config < Thor
      class Keychain
        include Cli

        attr_reader :app, :shell, :dir

        def initialize(app, shell, dir = '../travis-keychain')
          @app = app
          @shell = shell
          @dir = File.expand_path(dir)
        end

        def fetch
          chdir { pull }
          read
        end

        protected

          def pull
            error 'There are unstaged changes in your travis-keychain working directory.' unless clean?
            say 'Fetching the keychain ...'
            run 'git pull'
          end

          def read
            File.read(File.join(dir, "config/travis.#{app}.yml")) || ''
          end

          def chdir(&block)
            FileUtils.mkdir_p(dir)
            Dir.chdir(dir, &block)
          end

          def clean?
            `git status`.include?('working directory clean')
          end
      end
    end
  end
end
