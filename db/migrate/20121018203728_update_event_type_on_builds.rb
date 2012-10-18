class UpdateEventTypeOnBuilds < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE builds
        SET event_type = requests.event_type
        FROM requests
        WHERE builds.request_id = requests.id
    SQL
  end

  def down
  end
end
