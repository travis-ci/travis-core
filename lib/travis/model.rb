# This module is required for preloading classes on JRuby, see
#   https://github.com/travis-ci/travis-support/blob/master/lib/core_ext/module/load_constants.rb
# which is used in
#   https://github.com/travis-ci/travis-hub/blob/master/lib/travis/hub/cli.rb#L15
require 'core_ext/active_record/base'

module Travis
  module Model
    autoload :Artifact,    'travis/model/artifact'
    autoload :Build,       'travis/model/build'
    autoload :Commit,      'travis/model/commit'
    autoload :EnvHelpers,  'travis/model/env_helpers'
    autoload :Job,         'travis/model/job'
    autoload :Permission,  'travis/model/permission'
    autoload :Repository,  'travis/model/repository'
    autoload :Request,     'travis/model/request'
    autoload :SslKey,      'travis/model/ssl_key'
    autoload :Token,       'travis/model/token'
    autoload :User,        'travis/model/user'
    autoload :Worker,      'travis/model/worker'
  end
end
