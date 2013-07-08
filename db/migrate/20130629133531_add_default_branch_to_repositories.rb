class AddDefaultBranchToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :default_branch, :string
  end
end
