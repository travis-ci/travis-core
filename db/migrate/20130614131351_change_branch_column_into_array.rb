class ChangeBranchColumnIntoArray < ActiveRecord::Migration
  def up
    execute "alter table commits alter column branch TYPE text[] USING ARRAY[branch];"
    execute "alter table builds alter column branch TYPE text[] USING ARRAY[branch];"
    rename_column :builds, :branch, :branches
    rename_column :commits, :branch, :branches
  end

  def down
    execute "alter table commits alter column branch TYPE varchar USING branch[1];"
    execute "alter table builds alter column branch TYPE varchar USING branch[1];"
    rename_column :builds, :branches, :branch
    rename_column :commits, :branches, :branch
  end
end
