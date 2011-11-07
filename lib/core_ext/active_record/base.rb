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

    def adapter
      env = defined?(Rails) ? Rails.env : ENV['RAILS_ENV'] || 'test'
      adapter = configurations[env]['adapter']
      adapter == 'jdbcpostgresql' ? 'postgresql' : adapter
    end
  end
end

