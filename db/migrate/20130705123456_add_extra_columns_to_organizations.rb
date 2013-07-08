class AddExtraColumnsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :avatar_url, :string
    add_column :organizations, :location, :string
    add_column :organizations, :email, :string
    add_column :organizations, :company, :string
    add_column :organizations, :homepage, :string
  end
end
