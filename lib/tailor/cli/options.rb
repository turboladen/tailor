require 'erb'
require 'optparse'
require 'ostruct'
require 'text-table'
require_relative '../version'
require_relative '../configuration'

class Tailor
  class CLI
    class Options
      @output_color = true

      def self.parse!(args)
        options = OpenStruct.new
        options.config_file = ''
        options.formatters = []
        options.show_config = false
        options.style = {}

        opts = OptionParser.new do |opt|
          opt.banner = self.banner
          opt.separator ""
          opt.separator "  " + ("-" * 73)
          opt.separator ""
          opt.separator "Config file options:"
          opt.on('-s', '--show-config', 'Show your current config.') do
            options.show_config = true
          end

          opt.on('-c', '--config-file FILE',
            "Use a specific config file.") do |config|
            options.config_file = config
          end

          opt.on('--create-config', 'Create a new .tailor file') do
            if create_config
              msg = "Your new tailor config file was created at "
              msg << "#{Dir.pwd}."
              $stdout.puts msg
              exit
            else
              $stderr.puts "Creation of .tailor failed!"
              exit 1
            end
          end

          #---------------------------------------------------------------------
          # Style options
          #---------------------------------------------------------------------
          opt.separator ""
          opt.separator "Style Options:"
          opt.separator "  (Any option that doesn't have an explicit way of"
          opt.separator "  turning it off can be done so simply by passing"
          opt.separator "  passing it 'false'.)"

          opt.separator ""
          opt.separator "  * Horizontal Spacing:"
          opt.on('--allow-hard-tabs BOOL',
            'Check for hard tabs?  (default: true)') do |c|
            options.style[:allow_hard_tabs] = c
          end

          opt.on('--allow-trailing-line-spaces BOOL',
            'Check for trailing spaces at the end of lines?',
            '(default: true)') do |c|
            options.style[:allow_trailing_line_spaces] = c
          end

          opt.on('--indentation-spaces NUMBER',
            'Spaces to expect indentation.  (default: 2)') do |c|
            options.style[:indentation_spaces] = c
          end

          opt.on('--max-line-length NUMBER',
            'Max characters in a line. (default: 80)') do |c|
            options.style[:max_line_length] = c
          end

          opt.on('--spaces-after-comma NUMBER',
            'Spaces to expect after a comma.  (default: 1)') do |c|
            options.style[:spaces_after_comma] = c
          end

          opt.on('--spaces-before-comma NUMBER',
            'Spaces to expect before a comma.  (default: 0)') do |c|
            options.style[:spaces_before_comma] = c
          end

          opt.on('--spaces-after-lbrace NUMBER',
            'Spaces to expect after a {.  (default: 1)') do |c|
            options.style[:spaces_after_lbrace] = c
          end

          opt.on('--spaces-before-lbrace NUMBER',
            'Spaces to expect before a {.  (default: 1)') do |c|
            options.style[:spaces_before_lbrace] = c
          end

          opt.on('--spaces-before-rbrace NUMBER', Integer,
            'Spaces to expect before a }.  (default: 1)') do |c|
            options.style[:spaces_before_rbrace] = c
          end

          opt.on('--spaces-in-empty-braces NUMBER', Integer,
            'Spaces to expect between a { and }.  (default: 0)') do |c|
            options.style[:spaces_in_empty_braces] = c
          end

          opt.on('--spaces-after-lbracket NUMBER', Integer,
            'Spaces to expect after a [.  (default: 0)') do |c|
            options.style[:spaces_after_lbracket] = c
          end

          opt.on('--spaces-before-rbracket NUMBER', Integer,
            'Spaces to expect before a ].  (default: 0)') do |c|
            options.style[:spaces_before_rbracket] = c
          end

          opt.on('--spaces-after-lparen NUMBER', Integer,
            'Spaces to expect after a (.  (default: 0)') do |c|
            options.style[:spaces_after_lparen] = c
          end

          opt.on('--spaces-before-rparen NUMBER', Integer,
            'Spaces to expect before a ).  (default: 0)') do |c|
            options.style[:spaces_before_rparen] = c
          end

          opt.separator ""
          opt.separator ""

          opt.separator "  * Naming:"

          opt.on('--allow-camel-case-methods BOOL',
            'Check for camel-case method names?', '(default: true)') do |c|
            options.style[:allow_camel_case_methods] = instance_eval(c)
          end

          opt.on('--allow-screaming-snake-case-classes BOOL',
            'Check for classes like "My_Class"?', '(default: true)') do |c|
            options.style[:allow_screaming_snake_case_classes] =
              instance_eval(c)
          end

          opt.separator ""
          opt.separator ""
          opt.separator "  * Vertical Spacing"

          opt.on('--max-code-lines-in-class NUMBER', Integer,
            'Max number lines of code in a class.', '(default: 300)') do |c|
            options.style[:max_code_lines_in_class] = c
          end

          opt.on('--max-code-lines-in-method NUMBER', Integer,
            'Max number lines of code in a method.', '(default: 30)') do |c|
            options.style[:max_code_lines_in_method] = c
          end

          opt.on('--trailing-newlines NUMBER', Integer,
            'Newlines to expect at the end of the file.', '(default: 1)') do |c|
            options.style[:trailing_newlines] = c
          end

          #---------------------------------------------------------------------
          # Common options
          #---------------------------------------------------------------------
          opt.separator ""
          opt.separator "Common options:"

=begin
          opt.on('-f', '--format FORMATTER') do |format|
            options.formatters << format
          end
=end

          opt.on('--[no-]color', "Output in color") do |color|
            @output_color = color
          end

          opt.on_tail('-v', '--version', "Show the version") do
            puts version
            exit
          end

          opt.on_tail('-d', '--debug', "Turn on debug logging") do
            Tailor::Logger.log = true
          end

          opt.on_tail('-h', '--help', 'Show this message') do |help|
            puts opt
            exit
          end
        end

        opts.parse!(args)
        require_relative '../../ext/string_ext' if @output_color

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
        <<-USAGE
Usage:  tailor [options] [FILE|DIR|GLOB]

Examples:
tailor
tailor --no-color -d my_file.rb
tailor --config-file tailor_config lib/**/*.rb
tailor --show-config
        USAGE
      end

      def self.create_config
        if File.exists? Dir.pwd + '/.tailor'
          $stderr.puts "Can't create new config; it already exists."
          false
        else
          erb_file = File.expand_path(
            File.dirname(__FILE__) + '/../tailorrc.erb')
          formatters = Tailor::Configuration.default.formatters
          file_list = 'lib/**/*.rb'
          style = Tailor::Configuration.default.file_sets[:default][:style]
          default_config_file = ERB.new(File.read(erb_file)).result(binding)
          File.open('.tailor', 'w') { |f| f.write default_config_file }
        end
      end
    end
  end
end
