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
    autoload :FindUserAccounts,    'travis/services/find_user_accounts'
    autoload :FindUserPermissions, 'travis/services/find_user_permissions'
    autoload :FindWorker,          'travis/services/find_worker'
    autoload :FindWorkers,         'travis/services/find_workers'
    autoload :Helpers,             'travis/services/helpers'
    autoload :SyncUser,            'travis/services/sync_user_'     # TODO wtf, y u no load this file if named properly
    autoload :UpdateHook,          'travis/services/update_hook'
    autoload :UpdateJob,           'travis/services/update_job'
    autoload :UpdateUser,          'travis/services/update_user'
    autoload :UpdateWorkers,       'travis/services/update_workers'

    module Registry
      def add(key, const)
        services[key.to_sym] = const
      end

      def [](key)
        services[key.to_sym] || raise("can not use unregistered service #{key}")
      end

      private

        def services
          @services ||= {}
        end
    end

    extend Registry

    class << self
      def register
        constants(false).each do |name|
          const = const_get(name)
          Travis.services.add(name.to_s.underscore, const) if const < Base
        end
      end
    end
  end
end
