require 'logger'
require 'fig/lock/version'

module Fig::Lock::Log
  def log
    Fig::Lock::Log.log
  end
end

module Fig::Lock::Log
  class << self
    def log
      @log ||= Logger.new(STDOUT).tap do |l|
        l.level = Logger.const_get(ENV.fetch('LOG_LEVEL', 'INFO').upcase)
      end
    end
  end
end
