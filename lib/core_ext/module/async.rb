require 'thread'
require 'singleton'
require 'delegate'
require 'monitor'

class Async
  include Singleton

  def initialize
    @queue = Queue.new
    Thread.new { loop { work } }
  end

  def work
    block = @queue.pop
    block.call if block
  rescue Exception => e
    puts e.message, e.backtrace
  end

  def run(&block)
    @queue.push block
  end
end

class Work < Delegator
  include MonitorMixin

  attr_reader :result

  def initialize(&work)
    super(work)
    @work = work
    @done, @lock = false, new_cond
  end

  def process
    synchronize do
      @result, @done = @work.call, true
      @lock.signal
    end
  end

  def __getobj__
    synchronize do
      @lock.wait_while { !@done }
    end
    @result
  end

  def __setobj__(work)
    @work = work
  end
end

Module.class.class_eval do
  def async(*names)
    names.each do |name|
      method = instance_method(name)
      define_method(name) do |*args, &block|
        work = Work.new { method.bind(self).call(*args, &block) }
        Async.instance.run { work.process }
        work.result
      end
    end
  end
end
