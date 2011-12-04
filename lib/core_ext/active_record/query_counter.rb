module ActiveRecord
  module QueryCounter
    IGNORE = [/^PRAGMA (?!(table_info))/, /^SELECT attr.attname/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/]

    attr_reader :active, :count

    def run(&block)
      @active, @count = true, 0
      block.call
      @active = false
      @count
    end

    def call(name, start, finish, message_id, values)
      if active && !ignore?(values)
        # puts values[:sql]
        @count += 1
      end
    end

    def ignore?(values)
      'CACHE' == values[:name] || IGNORE.any? { |r| values[:sql].strip =~ r }
    end

    extend self
    ActiveSupport::Notifications.subscribe('sql.active_record', self)
  end
end

module ActiveRecord
  class Base
    def self.count_queries(&block)
      QueryCounter.run(&block)
    end
  end
end
