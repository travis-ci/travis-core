require 'travis/features'
require 'core_ext/hash/deep_symbolize_keys'

module Travis
  module Addons
    module Util
      class Template
        attr_reader :template, :data

        def initialize(template, data)
          @template = template
          @data = data.deep_symbolize_keys
        end

        def interpolate
          template.gsub(/%{(#{args.keys.join('|')}|.*)}/) { args[$1.to_sym] }
        end

        def args
          @args ||= {
            repository:            data[:repository][:slug],
            repository_slug:       data[:repository][:slug],
            repository_name:       data[:repository][:name],
            build_number:          data[:build][:number].to_s,
            build_id:              data[:build][:id].to_s,
            branch:                data[:commit][:branch],
            commit:                data[:commit][:sha][0..6],
            author:                data[:commit][:author_name],
            commit_message:        data[:commit][:message],
            result:                data[:build][:state].to_s,
            duration:              seconds_to_duration(data[:build][:duration]),
            message:               message,
            compare_url:           compare_url,
            build_url:             build_url
          }
        end

        def message
          Build::ResultMessage.new(data[:build]).full
        end

        def compare_url
          url = data[:commit][:compare_url]
          short_urls? ? shorten_url(url) : url
        end

        def build_url
          url = "http://#{Travis.config.host}/#{data[:repository][:slug]}/builds/#{data[:build][:id]}"
          short_urls? ? shorten_url(url) : url
        end

        private

          def short_urls?
            # # TODO Travis::Features wants full models, should probaly change that
            # repository = Repository.find(data['repository']['id'])
            # Travis::Features.active?(:short_urls, repository)
            false
          end

          def shorten_url(url)
            Url.shorten(url).short_url
          end

          def seconds_to_duration(seconds)
            (seconds / 60).floor.to_s + ' min ' + seconds.modulo(60).to_s + ' sec'
          end
      end
    end
  end
end
