require_relative '../ruler'
require_relative '../lexer_constants'

class Tailor
  module Rulers
    class CodeLinesInMethodRuler < Tailor::Ruler
      include LexerConstants

      def initialize(config)
        super(config)
        @method_start_lines = []
        @kw_start_lines = []
        @end_last_method = false
      end
      
      def ignored_nl_update(lexed_line, lineno, column)
        return if @method_start_lines.empty?
        return if lexed_line.only_spaces?
        return if lexed_line.comment_line?
        
        @method_start_lines.each do |line|
          line[:count] += 1
          log "Method from line #{line[:lineno]} now at #{line[:count]} lines."
        end
        
        if @end_last_method
          check_code_lines_count(@method_start_lines.last[:count],
            @method_start_lines.last[:lineno],
            @method_start_lines.last[:column])
          @method_start_lines.pop
          @end_last_method = false
        end
      end

      def kw_update(token, modifier, loop_with_do, lineno, column)
        if token == "def"
          @method_start_lines << { lineno: lineno, column: column, count: 0 }
          log "Method start lines: #{@method_start_lines}"
        end
        
        unless modifier ||
          !KEYWORDS_TO_INDENT.include?(token) ||
          (token == "do" && loop_with_do) ||
          CONTINUATION_KEYWORDS.include?(token)
          @kw_start_lines << lineno
          log "Keyword start lines: #{@kw_start_lines}"
        end
        
        if token == "end"
          log "Got 'end' of method."
          
          unless @method_start_lines.empty?
            if @method_start_lines.last[:lineno] == @kw_start_lines.last
              #msg = "Method from line #{@method_start_lines.last[:lineno]}"
              #msg << " was #{@method_start_lines.last[:count]} lines long."
              #log msg
              @end_last_method = true
            end
          end
          
          @kw_start_lines.pop
          log "End of keyword statement.  Keywords: #{@kw_start_lines}"
        end
      end
      
      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end
      
      def check_code_lines_count(actual_count, lineno, column)
        if actual_count > @config
          @problems << Problem.new(:code_lines_in_method, lineno, column,
            { actual_count: actual_count, should_be_at: @config })
        end
      end
    end
  end
end
