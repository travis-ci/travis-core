require 's3'
require 'travis/services/base'

module Travis
  module Services
    class FindCaches < Base
      register :find_caches

      class S3Wrapper
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

        def destroy
          s3_object.destroy
        end
      end

      class GcsWrapper
        attr_reader :storage, :bucket_name, :cache_object

        def initialize(storage, bucket_name, cache_object)
          @storage = storage
          @bucket_name = bucket_name
          @cache_object = cache_object
        end

        def last_modified
          cache_object.updated
        end

        def size
          Integer(cache_object.size)
        end

        def slug
          File.basename(cache_object.name, '.tbz')
        end

        def branch
          s3_object.name[%r{^\d+/(.*)/[^/]+$}, 1]
        end

        def destroy
          storage.delete_object(bucket_name, cache_object.name)
        end
      end

      def run
        return [] unless permission?
        c = caches(prefix: prefix)
        c.select! { |o| o.slug.include?(params[:match]) } if params[:match]
        c
      end

      private

        # def setup?
        #   return true if caches.any?
        #   logger.warn "[services:find-caches] S3 credentials missing"
        #   false
        # end

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

        def caches(options = {})
          c = []

          entries = Travis.config.to_h.fetch(:cache_options) { [] }
          entries = [entries] unless entries.is_a? Array

          entries.map do |entry|
            if config = entry[:s3]
              svc = ::S3::Service.new(config.to_h.slice(:secret_access_key, :access_key_id))
              bucket = svc.buckets.find(config.fetch(:bucket_name))
              next unless bucket
              c += bucket.objects(options).map { |object| S3Wrapper.new(repo, object) }
            elsif config = entry[:gcs]
              storage = ::Google::Apis::StorageV1::StorageService.new
              json_key_io = StringIO.new(config.to_h[:json_key])
              storage.authorization = ::Google::Auth::ServiceAccountCredentials.make_creds(
                json_key_io: json_key_io,
                scope: [
                  'https://www.googleapis.com/auth/devstorage.read_write'
                ]
              )
              bucket_name = config[:bucket_name]
              storage.list_objects(bucket_name, prefix: prefix).items.map do |object|
                GcsWrapper.new(storage, bucket_name, object)
              end
            end
          end

          c.compact
        end

    end
  end
end
