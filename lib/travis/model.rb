module Travis
  class Model
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
