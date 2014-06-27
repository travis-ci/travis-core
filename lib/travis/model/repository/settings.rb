# encoding: utf-8
require 'coercible'
require 'travis/settings'
require 'travis/overwritable_method_definitions'

class Repository::Settings < Travis::Settings
  class SshKey < Model
    field :name
    field :content, encrypted: true

    validates :name, presence: true
  end

  class SshKeys < Collection
    model SshKey
  end

  class EnvVar < Model
    field :name
    field :value, encrypted: true
    field :public, :boolean, default: false

    validates :name, presence: true
  end

  class EnvVars < Collection
    model EnvVar
  end

  register :ssh_keys
  register :env_vars

  add_setting :builds_only_with_travis_yml, :boolean, default: false
  add_setting :build_pushes, :boolean, default: true
  add_setting :build_pull_requests, :boolean, default: true
  add_setting :maximum_number_of_builds, :integer


  def maximum_number_of_builds
    super.to_i
  end

  def restricts_number_of_builds?
    maximum_number_of_builds > 0
  end
end

class Repository::DefaultSettings < Repository::Settings
  include Travis::DefaultSettings
end
