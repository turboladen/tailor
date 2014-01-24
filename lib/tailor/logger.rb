require 'log_switch'

class Tailor
  class Logger
    extend LogSwitch

    # Overrides the LogSwitch Logger to custom format the time format in log
    # messages.
    def self.logger
      return @logger if @logger
      @logger ||= ::Logger.new $stdout

      def @logger.format_message(_, time, _, msg)
        "[#{time.strftime('%Y-%m-%d %H:%M:%S')}]  #{msg}\n"
      end

      @logger
    end

    # Provides an .included hook to insert the name of the class for each log
    # message in the class that includes the Mixin.
    module Mixin
      def self.included(_)
        define_method :log do |*args|
          class_minus_main_name = self.class.to_s.sub(/^.*::/, '')
          args.first.insert(0, "<#{class_minus_main_name}> ")
          Tailor::Logger.log(*args)
        end
      end
    end
  end
end
