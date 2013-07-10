class AddUniqueIndexOnRepositoryOwnerNameAndName < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX index_repositories_on_owner_name_and_name"
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_repositories_on_owner_name_and_name ON repositories(owner_name, name)"
  end

  def down
    execute "DROP INDEX index_repositories_on_owner_name_and_name"
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_owner_name_and_name ON repositories(owner_name, name)"
  end
end
