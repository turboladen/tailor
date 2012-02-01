require 'log_switch'
require_relative 'tailor/runtime_error'
require_relative 'tailor/line_lexer'

class Tailor
  extend LogSwitch

  class << self
    # Main entry-point method.
    #
    # @param [String] path File or directory to check files in.
    def check_style(path)
      if File.file?(path)
        Tailor.log "Checking style of a single file."
        check_file(path)
      elsif File.directory?(path)
        Tailor.log "Checking style of a directory."
        Dir.glob(path).each { |f| check_file(f) }
      else
        raise Tailor::RuntimeError, "Not sure what this is: #{path}..."
      end
    end

    # @return [Hash] List of problem types and how many.
    def check_file file
      file_text = File.open(file, 'r').read
      lexer = Tailor::LineLexer.new(file_text)
      lexer.lex

      lexer.problems
    end

    # @todo This could delegate to Ruport (or something similar) for allowing
    #   output of different types.
    def print_report
      puts "#{problem_count} errors."
    end

    # @return [Hash]
    def problems
      @problems ||= {}
    end

    # @return [Fixnum] The number of problems found so far.
    def problem_count
      problems.empty? ? 0 : problems.values.inject(:+)
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
