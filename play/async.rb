require 'core_ext/module/async'
require 'logger'

class Logger
  async :debug
end

log = Logger.new STDOUT
log.debug "heloo"

sleep(0.1)
