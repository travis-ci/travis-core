class CreateMemberships < ActiveRecord::Migration
  def up
    create_table :memberships do |t|
      t.references :organization
      t.references :user
    end
  end

  def down
    drop_table :memberships
  end
end
