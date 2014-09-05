class AddEducationFieldToUser < ActiveRecord::Migration
  def change
    add_column :users, :education, :boolean
  end
end
