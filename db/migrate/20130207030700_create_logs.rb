class CreateLogs < ActiveRecord::Migration
  def up
    create_table :logs do |t|
      t.integer  :job_id
      t.text     :content
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :aggregated_at
      t.boolean  :archiving
      t.datetime :archived_at
      t.boolean  :archive_verified
    end

    add_index :logs, :job_id
    add_index :logs, :archive_verified
    add_index :logs, :archived_at

    # copy
    install_triggers
    # copy
  end

  def down
    remove_triggers
    drop_table :logs
  end

  def copy
    ActiveRecord::Base.connection.execute <<-sql
      INSERT INTO logs
        SELECT id, job_id, content, created_at, updated_at, aggregated_at, archiving, archived_at, archive_verified
        FROM artifacts
        WHERE artifacts.id NOT IN (SELECT id FROM logs)
    sql
  end

  def install_triggers
    ActiveRecord::Base.connection.execute <<-sql
      CREATE FUNCTION insert_log() RETURNS trigger LANGUAGE plpgsql AS $$
        BEGIN
          INSERT INTO logs VALUES (NEW.id, NEW.job_id, NEW.content, NEW.created_at, NEW.updated_at,
            NEW.aggregated_at, NEW.archiving, NEW.archived_at, NEW.archive_verified);
          RETURN NEW;
        END;
      $$;

      CREATE FUNCTION update_log() RETURNS trigger LANGUAGE plpgsql AS $$
        BEGIN
          UPDATE logs
          SET job_id=NEW.job_id, content=NEW.content, created_at=NEW.created_at,
            updated_at=NEW.updated_at, aggregated_at=NEW.aggregated_at, archiving=NEW.archiving,
            archived_at=NEW.archived_at, archive_verified=NEW.archive_verified
          WHERE id = NEW.id;
          RETURN NEW;
        END;
      $$;

      CREATE FUNCTION delete_log() RETURNS trigger LANGUAGE plpgsql AS $$
        BEGIN
          DELETE FROM logs WHERE id = OLD.id;
          RETURN OLD;
        END;
      $$;

      CREATE TRIGGER insert_log AFTER INSERT ON artifacts FOR EACH ROW
        EXECUTE PROCEDURE insert_log();

      CREATE TRIGGER update_log AFTER UPDATE ON artifacts FOR EACH ROW
        EXECUTE PROCEDURE update_log();

      CREATE TRIGGER delete_log AFTER DELETE ON artifacts FOR EACH ROW
        EXECUTE PROCEDURE delete_log();
    sql
  end

  def remove_triggers
    c = ActiveRecord::Base.connection
    %w(insert_log update_log delete_log).each do |name|
      c.execute("DROP TRIGGER #{name} ON artifacts CASCADE;")
      c.execute("DROP FUNCTION #{name}();")
    end
  end
end
