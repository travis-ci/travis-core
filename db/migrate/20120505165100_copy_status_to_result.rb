class CopyStatusToResult < ActiveRecord::Migration
  def self.up
    add_column :builds, :result, :integer
    add_column :jobs, :result, :integer
    add_column :repositories, :last_build_result, :integer

    queries = [
      'UPDATE builds SET result = status;',
      'UPDATE jobs SET result = status;',
      'UPDATE repositories SET last_build_result = last_build_status;',
    ]
    queries.each do |query|
      puts "Executing: #{query}"
      connection.execute(query)
    end
  end

  def self.down
    remove_column :builds, :result
    remove_column :jobs, :result
    remove_column :repositories, :last_build_result
  end
end
