class CreateLogParts < ActiveRecord::Migration
  def up
    create_table :log_parts do |t|
      t.integer  :log_id
      t.text     :content
      t.integer  :number
      t.boolean  :final
      t.datetime :created_at
    end

    add_index :log_parts, [:log_id, :number]

    copy
    install_triggers
    copy
  end

  def down
    remove_triggers
    drop_table :log_parts
  end

  def copy
    ActiveRecord::Base.connection.execute <<-sql
      INSERT INTO log_parts
        SELECT id, artifact_id, content, number, final, created_at
        FROM artifact_parts
        WHERE artifact_parts.id NOT IN (SELECT id FROM log_parts)
    sql
  end

  def install_triggers
    ActiveRecord::Base.connection.execute <<-sql
      CREATE FUNCTION insert_log_part() RETURNS trigger LANGUAGE plpgsql AS $$
        BEGIN
          INSERT INTO log_parts VALUES (NEW.id, NEW.artifact_id, NEW.content, NEW.number, NEW.final,
            NEW.created_at);
          RETURN NEW;
        END;
      $$;

      CREATE FUNCTION update_log_part() RETURNS trigger LANGUAGE plpgsql AS $$
        BEGIN
          UPDATE logs
          SET log_id=NEW.artifact_id, content=NEW.content, number=NEW.number, created_at=NEW.created_at
          WHERE id = NEW.id;
          RETURN NEW;
        END;
      $$;

      CREATE FUNCTION delete_log_part() RETURNS trigger LANGUAGE plpgsql AS $$
        BEGIN
          DELETE FROM log_parts WHERE id = OLD.id;
          RETURN OLD;
        END;
      $$;

      CREATE TRIGGER insert_log_part AFTER INSERT ON artifact_parts FOR EACH ROW
        EXECUTE PROCEDURE insert_log_part();

      CREATE TRIGGER update_log_part AFTER INSERT ON artifact_parts FOR EACH ROW
        EXECUTE PROCEDURE update_log_part();

      CREATE TRIGGER delete_log_part AFTER DELETE ON artifact_parts FOR EACH ROW
        EXECUTE PROCEDURE delete_log_part();
    sql
  end

  def remove_triggers
    c = ActiveRecord::Base.connection
    %w(insert_log_part update_log_part delete_log_part).each do |name|
      c.execute("DROP TRIGGER #{name} ON artifact_parts CASCADE;")
      c.execute("DROP FUNCTION #{name}();")
    end
  end
end
