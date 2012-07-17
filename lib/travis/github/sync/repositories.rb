require 'active_support/core_ext/class/attribute'

module Travis
  module Github
    module Sync
      # Fetches all repositories from Github which are in /user/repos or any of the user's
      # orgs/[name]/repos. Creates or updates existing repositories on our side and adds
      # it to the user's permissions. Also removes existing permissions for repositories
      # which are not in the received Github data. NOTE that this does *not* delete any
      # repositories because we do not know if the repository was deleted or renamed
      # on Github's side.
      class Repositories
        extend Travis::Instrumentation
        include Travis::Logging

        class_attribute :type
        self.type = 'public'

        class << self
          def private?
            self.type == 'private'
          end
        end

        attr_reader :user, :resources, :data

        def initialize(user)
          @user = user
          @resources = ['user/repos'] + user.organizations.map { |org| "orgs/#{org.login}/repos" }
        end

        def run
          with_github do
            { :synced => create_or_update, :removed => remove }
          end
        end
        instrument :run

        private

          def create_or_update
            data.map do |repository|
              Repository.new(user, repository).run
            end
          end

          def remove
            repos = user.repositories.select { |repo| !slugs.include?(repo.slug) }
            Repository.unpermit_all(user, repos)
            repos
          end

          # we have to filter these ourselves because the github api is broken for this
          def data
            @data ||= fetch.select { |repo| repo['private'] == self.class.private? }
          end

          def slugs
            @slugs ||= data.map { |repo| "#{repo['owner']['login']}/#{repo['name']}" }
          end

          def fetch
            resources.map { |resource| fetch_resource(resource) }.map(&:to_a).flatten.compact
          end
          instrument :fetch, :level => :debug

          def fetch_resource(resource)
            GH[resource] # should be: ?type=#{self.class.type}
          rescue Faraday::Error::ResourceNotFound => e
            log_exception(e)
          end

          def with_github(&block)
            # TODO in_parallel should return the block's result in a future version
            result = nil
            GH.with(:token => user.github_oauth_token) do
              # GH.in_parallel do
                result = yield
              # end
            end
            result
          end

          Travis::Notification::Instrument::Github::Sync::Repositories.attach_to(self)
      end
    end
  end
end



