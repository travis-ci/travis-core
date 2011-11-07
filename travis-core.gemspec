# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'travis_core/version'

Gem::Specification.new do |s|
  s.name         = "travis-core"
  s.version      = TravisCore::VERSION
  s.authors      = ["Sven Fuchs"]
  s.email        = "svenfuchs@artweb-design.de"
  s.homepage     = "https://github.com/travis-ci/travis-core"
  s.summary      = "[summary]"
  s.description  = "[description]"

  s.files        = Dir['{lib/**/*,spec/**/*,[A-Z]*}']
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
end
