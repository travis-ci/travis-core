class RepositoriesAddLastBuildState < ActiveRecord::Migration
  def change
    add_column :repositories, :last_build_state, :string
  end
end
