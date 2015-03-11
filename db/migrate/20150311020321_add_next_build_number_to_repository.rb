class AddNextBuildNumberToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :next_build_number, :integer
  end
end
