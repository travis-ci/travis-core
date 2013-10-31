require 's3'

module Travis
  class Cache
    def self.find_all(options = {})
      github_id = options[:github_id] || options[:repository].try(:github_id)
      branch    = options[:branch]
    end

    def initialize(s3)
      @s3 = s3
    end
    # class Service
    #   attr_reader :bucket_name, :secret_access_key, :access_key_id
    # 
    #   def initialize(options)
    #     options = { :s3 => options } unless options.include? :s3
    #     @bucket_name       = options[:s3].fetch(:bucket)
    #     @secret_access_key = options[:s3].fetch(:secret_access_key)
    #     @access_key_id     = options[:s3].fetch(:access_key_id)
    #   end
    # 
    #   def s3
    #     @s3 ||= S3::Service.new(:access_key_id => access_key_id, :secret_access_key => secret_access_key)
    #   end
    # 
    #   def bucket
    #     @bucket ||= s3.buckets.find(bucket_name)
    #   end
    # end
    # 
    # def self.service
    #   Thread.current[:cache_service] ||= Service.new(Travis.config.cache_options.to_hash)
    # end
    # 
    # def self.find_all(options)
    #   service.find_all(options)
    # end
    # 
    # FULL_SLUG = %r{^(\d+)/([^/]+)/([^/]+)\.tbz$}
    # attr_reader :github_id, :cache_slug, :service
    # attr_accessor :repository, :size, :last_modified, :etag
    # 
    # def initialize(service, options = {})
    #   @service    = service
    #   options     = normalize_options(options)
    #   @cache_slug = options.fetch(:cache_slug)
    #   @branch     = options.fetch(:branch)
    #   @github_id  = options.fetch(:github_id)
    #   @repository = options[:repository]
    # 
    #   options.each do |key, value|
    #     send("#{key}=", value) if respond_to? "#{key}="
    #   end
    # end
    # 
    # def full_slug
    #   "#{github_id}/#{branch}/#{cache_slug}.tbz"
    # end
    # 
    # def repository
    #   @repository ||= Repository.find_by_github_id(github_id)
    # end
    # 
    # private
    # 
    #   def parse_options(full_slug, options = {})
    #     raise ArgumentError, 'wrong slug fromat: %p' % full_slug unless m = FULL_SLUG.match(full_slug)
    #     options.merge(:github_id => m[1], :branch => m[2], :cache_slug => m[3])
    #   end
    # 
    #   def normalize_options(options)
    #     return parse(options.to_str)                                       if options.respond_to? :to_str
    #     return parse(options[:full_slug], options)                         if options[:full_slug]
    #     return options.merge(:github_id => options[:repository].github_id) if options[:repository]
    #     options
    #   end
  end
end
