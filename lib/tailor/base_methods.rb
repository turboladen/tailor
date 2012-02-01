require 'awesome_print'
require_relative 'line_lexer'

class Tailor
  module BaseMethods
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # @return [Hash]
      attr_accessor :problems

      # Delegates to
      def check_style(path)
        @problems = {}

        if File.file?(path)
          Tailor.log "This is a file!"
          check_file(path)
        elsif File.directory?(path)
          Dir.glob(path).each { |f| check_file(f) }
        else
          raise "Not sure what this is: #{path}; looks like it's a #{path.class}..."
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
end
