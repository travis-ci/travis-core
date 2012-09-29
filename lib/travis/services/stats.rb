module Travis
  module Services
    module Stats
      autoload :DailyRepos, 'travis/services/stats/daily_repos'
      autoload :DailyTests, 'travis/services/stats/daily_tests'
    end
  end
end
