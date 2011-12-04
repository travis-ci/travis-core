require 'active_record'

class ActiveRecord::Base
  SQL = {
    :floor => {
      'postgresql' => 'floor(%s::float)',
      'mysql'      => 'floor(%s)',
      'sqlite3'    => 'round(%s - 0.5)'
    }
  }
  class << self
    def floor(field)
      SQL[:floor][adapter] % field
    end

    # TODO extract this to somewhere else and use Travis.config.env instead
    def adapter
      env = defined?(Rails) ? Rails.env : ENV['ENV'] || ENV['RAILS_ENV'] || 'test'
      adapter = configurations[env]['adapter']
      adapter == 'jdbcpostgresql' ? 'postgresql' : adapter
    end
  end
end

