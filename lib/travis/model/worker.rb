require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/module/delegation'
require 'core_ext/hash/deep_symbolize_keys'
require 'redis'
require 'multi_json'
require 'securerandom'

class Worker
  autoload :Repository, 'travis/model/worker/repository'

  include Travis::Event
  extend Repository

  attr_reader :id, :attrs

  def initialize(id, attrs)
    @id = id
    @attrs = attrs
  end

  def update_attributes(attrs)
    self.class.update(id, attrs)
  end

  def touch
    self.class.touch(id)
  end

  [:full_name, :state, :payload].each do |name|
    define_method(name) { attrs[name] }
  end

  def host
    full_name.split(':').first
  end

  def name
    full_name.split(':').last
  end

  def job
    payload[:job] || {}
  end

  def repo
    payload[:repo] || {}
  end

  def queue
    attrs[:queue] || guess_queue
  end

  def ==(other)
    self.id == other.id
  end

  def <=>(other)
    full_name <=> other.full_name
  end

  def guess_queue
    case full_name
    when /ruby/, /staging/
      'builds.common'
    when /jvm/
      'builds.jvmotp'
    when /ppp/, /php/
      'builds.php'
    when /rails/
      'builds.rails'
    when /spree/
      'builds.spree'
    else
      raise "No idea what queue #{full_name} might use."
    end
  end
end
