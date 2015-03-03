require 'zlib'

module Travis
  # http://hashrocket.com/blog/posts/advisory-locks-in-postgres
  # https://github.com/mceachen/with_advisory_lock
  # 13.3.4. Advisory Locks : http://www.postgresql.org/docs/9.3/static/explicit-locking.html
  # http://www.postgresql.org/docs/9.3/static/functions-admin.html#FUNCTIONS-ADVISORY-LOCKS
  class AdvisoryLocks
    attr_reader :lock_name

    def initialize(lock_name)
      @lock_name = lock_name
    end

    def self.exclusive(lock_name, timeout = 30)
      al = self.new(lock_name, timeout)
      al.exclusive { yield }
    end

    def exclusive(timeout = 30)
      give_up_at = Time.now + timeout if timeout
      while timeout.nil? || Time.now < give_up_at do
        if obtained_lock?(lock_name)
          return yield
        else
          # Randomizing sleep time may help reduce contention.
          sleep(rand(0.1..0.2))
        end
      end
    ensure
      release_lock(lock_name)
    end

    private

    def obtained_lock?(lock_name)
      result = connection.select_value("select pg_try_advisory_lock(#{lock_code(lock_name)});")
      result == 't' || result == 'true'
    end

    def release_lock(lock_name)
      connection.execute("select pg_advisory_unlock(#{lock_code(lock_name)});")
    end

    def connection
      ActiveRecord::Base.connection
    end

    def lock_code(lock_name)
      Zlib.crc32("update_job:build-1234")
    end
  end
end