# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'travis_core/version'

Gem::Specification.new do |s|
  s.name         = "travis-core"
  s.version      = TravisCore::VERSION
  s.authors      = ["Travis CI"]
  s.email        = "contact@travis-ci.org"
  s.homepage     = "https://github.com/travis-ci/travis-core"
  s.summary      = "[summary]"
  s.description  = "[description]"

  s.files        = Dir['{lib/**/*,spec/**/*,[A-Z]*}']
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'

  s.add_dependency 'rake',              '~> 0.9.2'
  s.add_dependency 'thor',              '~> 0.14.6'
  s.add_dependency 'rails',             '~> 3.1.1' # why does devise require rails??
  s.add_dependency 'activerecord',      '~> 3.1.1'
  s.add_dependency 'actionmailer',      '~> 3.1.1'
  # s.add_dependency 'actionmailer_inline_css', '~> 1.3.0'

  # db
  s.add_dependency 'data_migrations',   '~> 0.0.1'

  # structures
  s.add_dependency 'hashr',             '~> 0.0.16'
  s.add_dependency 'rabl',              '~> 0.5.0'

  # app
  s.add_dependency 'devise',            '~> 1.4.2'
  s.add_dependency 'oa-oauth',          '~> 0.3.0'
  s.add_dependency 'simple_states',     '~> 0.1.0.pre1'

  # apis
  s.add_dependency 'octokit',           '~> 0.6.5'
  s.add_dependency 'pusher',            '~> 0.8.1'
end
