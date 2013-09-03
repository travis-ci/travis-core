# This module is required for preloading classes on JRuby, see
#   https://github.com/travis-ci/travis-support/blob/master/lib/core_ext/module/load_constants.rb
# which is used in
#   https://github.com/travis-ci/travis-hub/blob/master/lib/travis/hub/cli.rb#L15
require 'core_ext/active_record/base'

module Travis
  class Model < ActiveRecord::Base
    autoload :Account,         'travis/model/account'
    autoload :Broadcast,       'travis/model/broadcast'
    autoload :Build,           'travis/model/build'
    autoload :Commit,          'travis/model/commit'
    autoload :Email,           'travis/model/email'
    autoload :EncryptedColumn, 'travis/model/encrypted_column'
    autoload :EnvHelpers,      'travis/model/env_helpers'
    autoload :Job,             'travis/model/job'
    autoload :Log,             'travis/model/log'
    autoload :Membership,      'travis/model/membership'
    autoload :Organization,    'travis/model/organization'
    autoload :Permission,      'travis/model/permission'
    autoload :Repository,      'travis/model/repository'
    autoload :Request,         'travis/model/request'
    autoload :SslKey,          'travis/model/ssl_key'
    autoload :Token,           'travis/model/token'
    autoload :User,            'travis/model/user'
    autoload :Worker,          'travis/model/worker'

    self.abstract_class = true

    cattr_accessor :follower_connection_handler

    class << self
      def connection_handler
        if Thread.current['Travis.with_follower_connection_handler']
          follower_connection_handler
        else
          super
        end
      end

      def establish_follower_connection(spec)
        self.follower_connection_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new unless self.follower_connection_handler
        using_follower do
          self.establish_connection(spec)
        end
      end

      def using_follower
        Thread.current['Travis.with_follower_connection_handler'] = true
        yield
      ensure
        Thread.current['Travis.with_follower_connection_handler'] = false
      end
    end
  end
end
