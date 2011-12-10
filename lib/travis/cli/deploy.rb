require 'thor'

module Travis
  module Cli
    class Deploy < Thor
      include Cli

      namespace 'travis'

      desc 'deploy', 'Deploy to the given remote'
      method_option :migrate, :aliases => '-m', :type => :boolean, :default => false
      method_option :configure, :aliases => '-c', :type => :boolean, :default => false

      def deploy(remote)
        @remote = remote

        if clean?
          tag if production?
          configure if configure?
          push
          migrate if migrate?
        else
          error 'There are unstaged changes.'
        end
      end

      protected

        attr_reader :remote

        def clean?
          `git status`.include?('working directory clean')
        end

        def push
          say "Deploying to #{remote}"
          run "git push #{remote} HEAD:master"
        end

        def tag
          say "Tagging #{version}"
          with_branch('production') do |branch|
            run "git reset --hard #{branch}"
            run 'git push origin production'
          end
          run "git tag -a 'deploy #{version}' -m 'deploy #{version}'"
          run 'git push --tags'
        end

        def with_branch(target)
          current = branch
          run "git checkout #{target}"
          yield current
          run "git checkout #{current}"
        end

        def branch
          `git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1 /'`
        end

        def version
          @version ||= "deploy #{Time.now.utc.strftime('%Y-%m-%d %H:%M')}"
        end

        def production?
          remote == 'production'
        end

        def configure?
          !!options[:configure]
        end

        def configure
          invoke Config, :sync, [remote], :restart => false
        end

        def migrate?
          !!options[:migrate]
        end

        def migrate
          run "heroku run rake db:migrate -r #{remote}"
        end
    end
  end
end
