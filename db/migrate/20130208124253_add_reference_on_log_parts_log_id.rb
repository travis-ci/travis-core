class AddReferenceOnLogPartsLogId < ActiveRecord::Migration
  def up
    execute "ALTER TABLE log_parts ADD CONSTRAINT log_parts_log_id_fk FOREIGN KEY (log_id) REFERENCES logs (id);"
  end

  def down
    execute "ALTER TABLE log_parts REMOVE CONSTRAINT log_parts_log_id_fk;"
  end
end
