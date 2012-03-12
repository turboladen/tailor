require 'optparse'
require_relative '../version'

class Tailor
  class CLI
    class Options
      def self.parse!(args)
        options = {}

        opts = OptionParser.new do |o|
          o.banner = self.banner
          o.separator ""
          o.separator "pants"
          o.on('-c', '--config-file [FILE]', "Use a specific config file") do |config|
            options[:config_file] = config
          end

          o.on('-d', '--debug', "Turn on debug logging") do |debug|
            options[:debug] = debug
          end

          o.on_tail('-h', '--help', 'Show this message') do |help|
            puts opts
            exit
          end
        end

        if args.empty?
          p opts
          exit
        end

        opts.parse!(args)

        options
      end

      # @return [String]
      def self.banner
        ruler + about + "\r\n" + usage + "\r\n"
      end

      # @return [String]
      def self.version
        ruler + about + "\r\n"
      end

      # @return [String]
      def self.ruler
        <<-RULER
  _________________________________________________________________________
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  |     |     |     |     |     |     |     |     |     |     |     |     |
  |           |           |           |           |           |           |
  |           1           2           3           4           5           |
  |                                                                       |
  -------------------------------------------------------------------------
        RULER
      end

      # @return [String]
      def self.about
        <<-ABOUT
  tailor (v#{Tailor::VERSION}).  \t\tA Ruby style checker.
\t\t\t\t\thttp://github.com/turboladen/tailor
        ABOUT
      end


      # @return [String]
      def self.usage
        <<-USEAGE
  Usage:
    $ #{File.basename($0)} [directory with .rb files]
      -OR-
    $ #{File.basename($0)} [single .rb file]"
        USEAGE
      end
    end
  end
end
