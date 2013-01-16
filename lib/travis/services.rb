module Travis
  module Services
    autoload :Base,                'travis/services/base'
    autoload :FindAdmin,           'travis/services/find_admin'
    autoload :FindArtifact,        'travis/services/find_artifact_' # TODO wtf, y u no load this file if named properly
    autoload :FindBranches,        'travis/services/find_branches'
    autoload :FindBuild,           'travis/services/find_build'
    autoload :FindBuilds,          'travis/services/find_builds'
    autoload :FindDailyReposStats, 'travis/services/find_daily_repos_stats'
    autoload :FindDailyTestsStats, 'travis/services/find_daily_tests_stats'
    autoload :FindEvents,          'travis/services/find_events'
    autoload :FindHooks,           'travis/services/find_hooks'
    autoload :FindJob,             'travis/services/find_job'
    autoload :FindJobs,            'travis/services/find_jobs'
    autoload :FindRepo,            'travis/services/find_repo'
    autoload :FindRepos,           'travis/services/find_repos'
    autoload :FindRepoKey,         'travis/services/find_repo_key'
    autoload :FindUserAccounts,    'travis/services/find_user_accounts'
    autoload :FindUserBroadcasts,  'travis/services/find_user_broadcasts'
    autoload :FindUserPermissions, 'travis/services/find_user_permissions'
    autoload :FindWorker,          'travis/services/find_worker'
    autoload :FindWorkers,         'travis/services/find_workers'
    autoload :Helpers,             'travis/services/helpers'
    autoload :RegenerateRepoKey,   'travis/services/regenerate_repo_key'
    autoload :ResetModel,          'travis/services/reset_model'
    autoload :SyncUser,            'travis/services/sync_user_'     # TODO wtf, y u no load this file if named properly
    autoload :UpdateHook,          'travis/services/update_hook'
    autoload :UpdateJob,           'travis/services/update_job'
    autoload :UpdateUser,          'travis/services/update_user'
    autoload :UpdateWorkers,       'travis/services/update_workers'

    module Registry
      def add(key, const = nil)
        if key.is_a?(Hash)
          key.each { |key, const| add(key, const) }
        else
          services[key.to_sym] = const
        end
      end

      def [](key)
        services[key.to_sym] || raise("can not use unregistered service #{key}. known services are: #{services.keys.inspect}")
      end

      private

        def services
          @services ||= {}
        end
    end

    extend Registry

    class << self
      def register
        constants(false).each { |name| const_get(name) }
      end
    end
  end
end
