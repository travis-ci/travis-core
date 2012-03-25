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
          replace_keywords(template).strip
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

        def commit
          build.commit.commit[0, 7]
        end

        def author
          build.commit.author_name
        end

        def message
          build.human_status_message
        end

        def compare_url
          shorten_url(build.commit.compare_url)
        end

        def build_url
          repo = build.repository
          url  = [Travis.config.http_host, repo.owner_name, repo.name, 'builds', build.id].join('/')
          shorten_url(url)
        end

        private

        def replace_keywords(content)
          content.gsub(/%{(#{ACCEPTED_KEYWORDS.join("|")}|.*)}/) do
            send($1) if $1 && self.respond_to?($1)
          end
        end

        def shorten_url(url)
          Url.shorten(url).short_url
        end
      end
    end
  end
end
