# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'travis_core/version'

Gem::Specification.new do |s|
  s.name         = "travis-core"
  s.version      = TravisCore::VERSION
  s.authors      = ["Travis CI"]
  s.email        = "contact@travis-ci.org"
  s.homepage     = "https://github.com/travis-ci/travis-core"
  s.summary      = "The heart of Travis"

  s.files        = Dir['{lib/**/*,spec/**/*,[A-Z]*}']
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'

  s.add_dependency 'rake',              '~> 0.9.2.2'
  s.add_dependency 'thor',              '~> 0.14.6'
  s.add_dependency 'activerecord',      '~> 3.2.3'
  s.add_dependency 'actionmailer',      '~> 3.2.3'
  s.add_dependency 'railties',          '~> 3.2.3'
  s.add_dependency 'postmark-rails',    '~> 0.4.1'
  s.add_dependency 'rollout',           '~> 1.1.0'

  # db
  s.add_dependency 'data_migrations',   '~> 0.0.1'
  s.add_dependency 'redis',             '~> 2.2.2'


  # structures
  s.add_dependency 'hashr',             '~> 0.0.19'
  s.add_dependency 'metriks',           '~> 0.9.7'

  # app
  s.add_dependency 'simple_states',     '~> 0.1.1'

  # apis
  s.add_dependency 'pusher',            '~> 0.9.2'
  s.add_dependency 'gh'
  s.add_dependency 'multi_json'
end
