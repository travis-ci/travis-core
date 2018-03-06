namespace :db do
  env = ENV["RAILS_ENV"]
  desc "Create and migrate the #{env} database"
  task :create do
    sh "createdb travis_#{env}" rescue nil
    sh "psql -q travis_#{env} < #{Gem.loaded_specs['travis-migrations'].full_gem_path}/db/main/structure.sql"
  end
end
