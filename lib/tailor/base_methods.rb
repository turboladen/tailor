require 'awesome_print'
require_relative 'line_lexer'

class Tailor
  module BaseMethods
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def check_style(object)
        if File.file?(object)
          Tailor.log "This is a file!"
          check_file(object)
        elsif File.directory?(object)
          check_directory(object)
        else
          raise "Not sure what this is: #{object}; looks like it's a #{object.class}..."
        end
      end

      def check_file file
        file_text = File.open(file, 'r').read
        lexer = Tailor::LineLexer.new(file_text)
        lexer.lex
      end

      def print_report
        # Stubbing for now
      end

      def problem_count
        # Stubbing for now
        0
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
