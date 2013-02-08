class AddNotNullConstraintOnLogPartsLogId < ActiveRecord::Migration
  def up
    execute "ALTER TABLE log_parts ALTER COLUMN log_id SET NOT NULL;"
  end

  def down
    execute "ALTER TABLE log_parts ALTER COLUMN log_id DROP NOT NULL;"
  end
end
