require 'travis/features'

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
          if short_urls_enabled?
            shorten_url(build.commit.compare_url)
          else
            build.commit.compare_url
          end
        end

        def build_url
          if short_urls_enabled?
            repo = build.repository
            url  = [Travis.config.http_host, repo.owner_name, repo.name, 'builds', build.id].join('/')
            shorten_url(url)
          else
            long_build_url(build)
          end
        end

        private

        def long_build_url(build)
          host = Travis.config.http_host
          repo = build.repository
          "#{host}/#{repo.owner_name}/#{repo.name}/builds/#{build.id}"
        end

        def replace_keywords(content)
          content.gsub(/%{(#{ACCEPTED_KEYWORDS.join("|")}|.*)}/) do
            send($1) if $1 && self.respond_to?($1)
          end
        end

        def short_urls_enabled?
          Travis::Features.active?(:short_urls, build.repository)
        end

        def shorten_url(url)
          Url.shorten(url).short_url
        end
      end
    end
  end
end
