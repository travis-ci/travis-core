require 'ostruct'
require 'active_support/core_ext/string/inflections'
require 'core_ext/ostruct/hash_access'
require 'active_support/json'
require 'net/http'

# TODO: either port this to Octokit or use Hashr instead of OpenStruct
module Github
  module Api
    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      def fetch(data)
        new(data).fetch
      end
    end

    def fetch
      uri = URI.parse("http://github.com/api/v2/json/#{path}")
      response = Net::HTTP.get_response(uri)
      data = ActiveSupport::JSON.decode(response.body)
      key  = self.class.name.demodulize.underscore
      data.replace(data[key]) if data.key?(key)
      self.class.new(data)
    end
  end

  module ServiceHook
    class Payload < OpenStruct
      attr_reader :payload

      def initialize(payload)
        @payload = payload
        payload = ActiveSupport::JSON.decode(payload) if payload.is_a?(String)
        super(payload)
      end
    end

    class Push < Payload
      def repository
        @repository ||= Repository.new(super)
      end

      def last_commit
        commits.last
      end

      def commits
        @commits ||= Array(self['commits']).map do |commit|
          Commit.new(commit.merge('ref' => ref, 'compare_url' => compare_url), repository)
        end
      end

      def compare_url
        self['compare']
      end
    end

    class PullRequest < Payload
      def links
        pull_request["_links"]
      end

      def comments_url
        links["comments"]
      end

      def base_commit
        @base_commit ||= Commit.new({'ref' => pull_request["base"]["sha"]}, repository)
      end

      def base_repository
        @base_repository ||= Repository.new(pull_request["base"]["repo"])
      end

      def head_repository
        @head_repository ||= Repository.new(pull_request["head"]["repo"])
      end

      alias repository head_repository

      def head_commit
        @head_commit ||= begin
          commit = {
            'ref'         => pull_request["head"]["ref"],
            'id'          => pull_request["head"]["sha"],
            'compare_url' => links["html"],
            'message'     => pull_request["title"],
            'timestamp'   => pull_request["head"]["repo"]["pushed_at"]
          }
          Commit.new(commit, repository)
        end
      end

      alias last_commit head_commit
    end
  end

  class Repository < OpenStruct
    include Api

    ATTR_NAMES = [:name, :description, :url, :owner_name, :owner_email]

    def to_hash
      ATTR_NAMES.inject({}) { |result, name| result.merge(name => self.send(name)) }
    end

    def owner_name
      owner.is_a?(Hash) ? owner['login'] || owner['name'] : owner
    end

    def owner_email
      if owner.is_a?(Hash) && email = owner['email']
        return email if email
      end

      if organization
        Organization.fetch(:name => organization).member_emails
      else
        User.fetch(:name => owner_name).email
      end
    end

    def path
      "repos/show/#{owner_name}/#{name}"
    end

    def private?
      self['private']
    end
  end

  class Commit < OpenStruct
    ATTR_NAMES = [:commit, :message, :branch, :committed_at, :committer_name, :committer_email, :author_name, :author_email, :compare_url]

    def initialize(data, repository)
      data['author'] ||= {}
      data['repository']  = repository
      super(data)
    end

    def to_hash
      ATTR_NAMES.inject({}) { |result, name| result.merge(name => self.send(name)) }
    end

    def commit
      self['id']
    end

    def branch
      (self['ref'] || '').gsub(/^refs\/heads\//, '')
    end

    def committed_at
      self['timestamp']
    end

    def committer
      self['committer'] || {}
    end

    def committer_name
      committer['name']
    end

    def committer_email
      committer['email']
    end

    def author
      self['author'] || {}
    end

    def author_name
      author['name']
    end

    def author_email
      author['email']
    end

    def compare_url
      self['compare_url']
    end
  end

  class Organization < OpenStruct
    include Api

    def member_emails
      users.map { |user| user['email'] }.select(&:present?).join(',')
    end

    def path
      "organizations/#{name}/public_members"
    end
  end

  class User < OpenStruct
    include Api

    def path
      "user/show/#{name}"
    end
  end
end


