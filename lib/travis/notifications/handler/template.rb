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
          minify_uris(replace_keywords(template)).strip
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
          build.commit.compare_url
        end

        def build_url
          [Travis.config.host, build.repository.owner_name, build.repository.name, 'builds', build.id].join('/')
        end

        def replace_keywords(content)
          content.gsub(/%{(#{ACCEPTED_KEYWORDS.join("|")}|.*)}/) do
            send($1) if $1 && self.respond_to?($1)
          end
        end

        def minify_uris(content)
          content.gsub /(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?/ix do |url|
            [Travis.config.shorten_host, Url.find_or_create_by_url(url).code].join('/')
          end
        end
      end
    end
  end
end
