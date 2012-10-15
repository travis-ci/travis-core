class RequestsAddResultAndMessage < ActiveRecord::Migration
  def change
    add_column :requests, :result, :string
    add_column :requests, :message, :string
  end
end

