# This module is required for preloading classes on JRuby, see
#   https://github.com/travis-ci/travis-support/blob/master/lib/core_ext/module/load_constants.rb
# which is used in
#   https://github.com/travis-ci/travis-hub/blob/master/lib/travis/hub/cli.rb#L15
module Travis
  module Model
    autoload :Artifact,    'travis/model/artifact'
    autoload :Build,       'travis/model/build'
    autoload :Commit,      'travis/model/commit'
    autoload :Job,         'travis/model/job'
    autoload :Repository,  'travis/model/repository'
    autoload :Request,     'travis/model/request'
    autoload :ServiceHook, 'travis/model/service_hook'
    autoload :SslKey,      'travis/model/ssl_key'
    autoload :Token,       'travis/model/token'
    autoload :User,        'travis/model/user'
    autoload :Worker,      'travis/model/worker'
  end
end
