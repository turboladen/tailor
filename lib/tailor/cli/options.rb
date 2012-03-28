require 'erb'
require 'optparse'
require 'text-table'
require_relative '../version'
require_relative '../configuration'

class Tailor
  class CLI
    class Options
      def self.parse!(args)
        options = {}

        opts = OptionParser.new do |o|
          o.banner = self.banner
          o.separator ""

          o.on('-c', '--color', "Output in color") do |color|
            require_relative '../../ext/string_ext'
          end

          o.on('-f', '--config-file FILE',
            "Use a specific config file") do |config|
            options[:config_file] = config
          end

          o.on('-s', '--show-config', 'Show your current config') do
            options[:show_config] = true
          end

          o.on('', '--create-config', 'Create a new ~/.tailorrc') do
            if create_config
              msg = "Your new tailorrc file was created at "
              msg << "#{Tailor::Configuration::DEFAULT_RC_FILE}"
              $stdout.puts msg
              exit
            else
              $stderr.puts "Creation of ~/.tailorrc failed."
              exit 1
            end
          end

          o.on_tail('-v', '--version', "Show the version") do
            puts version
            exit
          end

          o.on_tail('-d', '--debug', "Turn on debug logging") do
            Tailor::Logger.log = true
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
        "  Usage:  tailor [FILE|DIR]"
      end

      def self.create_config
        if File.exists? Tailor::Configuration::DEFAULT_RC_FILE
          $stderr.puts "Can't create new config; it already exists."
          false
        else
          erb_file = File.expand_path(
            File.dirname(__FILE__) + '/../../../tailor_config.yaml.erb')
          default_config_file = ERB.new(File.read(erb_file)).result(binding)
          File.write(
            Tailor::Configuration::DEFAULT_RC_FILE, default_config_file)
        end
      end
    end
  end
end
