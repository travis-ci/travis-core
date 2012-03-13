module Travis
  module Notifications
    module Handler
      class Template
        attr_reader :template, :build

        ACCEPTED_KEYWORDS = %w{repository_url build_number branch commit_short commit author message compare_url build_url}

        def initialize(template, build)
          @template, @build = template, build
        end

        def interpolate
          template.gsub(/%{(#{ACCEPTED_KEYWORDS.join("|")}|.*)}/) do
            send($1) if $1 && self.respond_to?($1.to_sym)
          end.strip
        end

        def repository_url
          build.repository.slug
        end

        def build_number
          build.number.to_s
        end

        def branch
          build.commit.branch
        end

        def commit_short
          build.commit.commit[0, 7]
        end

        def commit
          build.commit.commit
        end

        def author
          build.commit.author_name
        end

        def message
          build.human_status_message
        end

        def compare_url
          build.commit.compare_url
        end

        def build_url
          [Travis.config.host, build.repository.owner_name, build.repository.name, 'builds', build.id].join('/')
        end
      end
    end
  end
end