require_relative '../ruler'


class Tailor
  module Rulers
    class AllowInvalidRubyRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :file_beg
      end

      def file_beg_update(file_name)
        @file_name = file_name
        measure
      end

      # @return [Boolean]
      def invalid_ruby?
        log 'Checking for valid Ruby...'
        result = `"#{Gem.ruby}" -c "#{@file_name}"`

        result.size.zero?
      end

      def measure
        if invalid_ruby? && @config == false
          lineno = 0
          column = 0
          msg = 'File contains invalid Ruby; run `ruby -c [your_file.rb]` '
          msg << 'for more details.'

          @problems << Problem.new(problem_type, lineno, column, msg,
            @options[:level])
        end
      end
    end
  end
end
