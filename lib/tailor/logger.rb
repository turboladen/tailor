require 'log_switch'

class Tailor
  class Logger
    extend LogSwitch

    def self.logger
      return @logger if @logger
      @logger ||= ::Logger.new $stdout

      def @logger.format_message(level, time, progname, msg)
        "[#{time.strftime("%Y-%m-%d %H:%M:%S")}]  #{msg}\n"
      end

      @logger
    end
  end
end
