class OrganizationsCreate < ActiveRecord::Migration
  def up
    create_table :organizations do |t|
      t.string   :name
      t.string   :login
      t.integer  :github_id
      t.timestamps
    end
  end

  def down
    drop_table :organizations
  end
end
