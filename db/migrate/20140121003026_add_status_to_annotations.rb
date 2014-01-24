class AddStatusToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :status, :string
  end
end
