class AddIndexOnGithubIdToOrganizations < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_organizations_on_github_id ON organizations(github_id)"
  end

  def down
    execute "DROP INDEX index_organizations_on_github_id"
  end
end
