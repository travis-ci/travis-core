require 'active_support/core_ext/class/attribute'

module Travis
  module Services
    module Github
      class SyncUser
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
              repos = user.repositories.reject { |repo| slugs.include?(repo.slug) }
              Repository.unpermit_all(user, repos)
              repos
            end

            # we have to filter these ourselves because the github api is broken for this
            def data
              @data ||= filter_duplicates(filter_based_on_repo_permission)
            end

            def filter_based_on_repo_permission
              fetch.select { |repo| repo['private'] == self.class.private? }
            end

            def filter_duplicates(repositories)
              repositories.each_with_object([]) do |repository, filtered_list|
                unless in_filtered_list?(filtered_list, repository)
                  filtered_list.push(repository)
                end
              end
            end

            def in_filtered_list?(filtered_list, other_repository)
              filtered_list.any? do |existing_repository|
                same_repository_with_admin?(existing_repository, other_repository)
              end
            end

            def same_repository_with_admin?(existing_repository, other_repository)
              existing_repository['owner']['login'] == other_repository['owner']['login'] and
                existing_repository['name'] == other_repository['name'] and
                existing_repository['permissions']['admin'] == true
            end

            def slugs
              @slugs ||= data.map { |repo| "#{repo['owner']['login']}/#{repo['name']}" }
            end

            def fetch
              resources.map { |resource| fetch_resource(resource) }.map(&:to_a).flatten.compact
            end
            instrument :fetch, :level => :debug

            def fetch_resource(resource)
              GH[resource] # TODO should be: ?type=#{self.class.type} but GitHub doesn't work as documented
            rescue GH::Error => e
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

            Travis::Notification::Instrument::Services::Github::SyncUser::Repositories.attach_to(self)
        end
      end
    end
  end
end
