require 'yaml'
require 'log_switch'
require 'awesome_print'
require_relative 'tailor/runtime_error'
require_relative 'tailor/line_lexer'

class Tailor
  extend LogSwitch

  self.log = true

  class << self
    # Main entry-point method.
    #
    # @param [String] path File or directory to check files in.
    def check_style(path)
      if File.file?(path)
        Tailor.log "Checking style of a single file: #{path}."
        check_file(path)
      elsif File.directory?(path)
        Tailor.log "Checking style of directory: #{path}"
        Dir.glob("#{path}/**/*").each do |child|
          Tailor.log "Checking style of file: #{child}."
          check_style(child)
        end
      else
        raise Tailor::RuntimeError, "Not sure what this is: #{path}..."
      end
    end

    # Adds problems found from Lexing to the {problems} list.
    #
    # @param [String] file The file to open, read, and check.
    def check_file file
      lexer = Tailor::LineLexer.new(file)
      lexer.lex
      p lexer.problems
      problems.concat(lexer.problems)
    end

    # @todo This could delegate to Ruport (or something similar) for allowing
    #   output of different types.
    def print_report
      puts "Problems:"
      problems.each { |problem| p problem }
      puts "problem count: #{problem_count}"
    end

    # @return [Hash]
    def problems
      @problems ||= []
    end

    # @return [Fixnum] The number of problems found so far.
    def problem_count
      problems.size
    end

    # Checks to see if +path_to_check+ is a real file or directory.
    #
    # @param [String] path_to_check
    # @return [Boolean]
    def checkable? path_to_check
      File.file?(path_to_check) || File.directory?(path_to_check)
    end

    # Tries to load a config file from ~/.tailor, then fails back on default
    # settings.
    def config
      user_config_file =
        File.expand_path(Dir.home + '/.tailor')
      puts "user config file: #{user_config_file}"
      default_config_file =
        File.expand_path(File.dirname(__FILE__) + '/../tailor_config.yaml')

      @config ||= if File.exists? user_config_file
        YAML.load_file user_config_file
                  else
        YAML.load_file default_config_file
      end
    end
  end
end
