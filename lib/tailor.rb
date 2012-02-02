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
        Dir.glob(path).each do |f|
          Tailor.log "Checking style of file: #{path}."
          check_file(f)
        end
      else
        raise Tailor::RuntimeError, "Not sure what this is: #{path}..."
      end
    end

    # Adds problems found from Lexing to the {problems} list.
    #
    # @param [String] file The file to open, read, and check.
    def check_file file
      file_text = File.open(file, 'r').read
      lexer = Tailor::LineLexer.new(file_text)
      lexer.lex
       p lexer.problems
      problems.concat(lexer.problems)
    end

    # @todo This could delegate to Ruport (or something similar) for allowing
    #   output of different types.
    def print_report
      puts "Problems:"
      problems.each { |problem| p problem }
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
  end
end
