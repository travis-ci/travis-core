require 'travis'

module Travis
  class Engine < Rails::Engine
    initializer 'add migrations path' do |app|
      # need to insert to migrations_paths on Migrator because Rails' stupid
      # rake tasks copy them over before loading the engines (Rails <= 3.2.2)
      ActiveRecord::Migrator.migrations_paths << root.join('db/migrate').to_s
    end
  end
end
