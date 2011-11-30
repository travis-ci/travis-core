require 'active_record'

class Worker < ActiveRecord::Base
  autoload :States, 'travis/model/worker/states'

  include States

  class << self
    def prune
      workers = where(['last_seen_at < ?', Time.now.utc - Travis.config.workers.prune.after]).destroy_all
      workers.each { |worker| worker.notify(:remove) }
    end
  end

  before_create do
    self.last_seen_at = Time.now.utc
  end

  def full_name
    [host, name].join(':')
  end
end
