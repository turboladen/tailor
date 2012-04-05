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

    module Mixin
      def self.included(base)
        define_method :log do |*args|
          args.first.insert(0, "<#{self.class}> ")
          Tailor::Logger.log(*args)
        end
      end
    end
  end
end
