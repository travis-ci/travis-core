require 's3'
require 'travis/services/base'

module Travis
  module Services
    class FindCaches < Base
      register :find_caches

      class Wrapper
        attr_reader :repository, :s3_object

        def initialize(repository, s3_object)
          @repository = repository
          @s3_object  = s3_object
        end

        def last_modified
          s3_object.last_modified
        end

        def size
          Integer(s3_object.size)
        end

        def slug
          File.basename(s3_object.key, '.tbz')
        end

        def branch
          s3_object.key[%r{^\d+/(.*)/[^/]+$}, 1]
        end
      end

      def run
        return [] unless setup? and permission?
        caches = objects(prefix: prefix).map { |object| Wrapper.new(repo, object) }
        caches.select! { |o| o.slug.include?(params[:match]) } if params[:match]
        caches
      end

      private

        def setup?
          return true if buckets.any?
          logger.warn "[services:find-caches] S3 credentials missing"
          false
        end

        def permission?
          current_user.permission?(required_role, repository_id: repo.id)
        end

        def required_role
          Travis.config.roles.find_cache || "push"
        end

        def repo
          @repo ||= run_service(:find_repo, params)
        end

        def branch
          params[:branch].presence
        end

        def prefix
          prefix = "#{repo.github_id}/"
          prefix << branch << '/' if branch
          prefix
        end

        def objects(options)
          buckets.flat_map { |b| b.objects(options) }
        end

        def buckets
          @buckets ||= begin
            entries = Travis.config.to_h.fetch(:cache_options) { [] }
            entries = [entries] unless entries.is_a? Array
            entries.map do |entry|
              next unless config = entry[:s3]
              service = ::S3::Service.new(config.slice(:secret_access_key, :access_key_id))
              service.buckets.find(config.fetch(:bucket_name))
            end.compact
          end
        end
    end
  end
end
