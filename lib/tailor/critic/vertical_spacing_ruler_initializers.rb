require_relative '../rulers'

class Tailor
  class Critic
    module VerticalSpacingRulerInitializers
      include Tailor::Rulers

      def init_code_lines_in_class_ruler(v_spacing_ruler, lexer)
        if @config[:vertical_spacing][:max_code_lines_in_class]
          code_lines_in_class_ruler = CodeLinesInClassRuler.new(
            @config[:vertical_spacing][:max_code_lines_in_class]
          )
          v_spacing_ruler.add_child_ruler(code_lines_in_class_ruler)
          [
            :add_ignored_nl_observer,
            :add_kw_observer,
            :add_nl_observer
          ].each { |o| lexer.send(o, code_lines_in_class_ruler) }
        end
      end

      def init_code_lines_in_method_ruler(v_spacing_ruler, lexer)
        if @config[:vertical_spacing][:max_code_lines_in_method]
          code_lines_in_method_ruler = CodeLinesInMethodRuler.new(
            @config[:vertical_spacing][:max_code_lines_in_method]
          )
          v_spacing_ruler.add_child_ruler(code_lines_in_method_ruler)
          [
            :add_ignored_nl_observer,
              :add_kw_observer,
              :add_nl_observer
          ].each { |o| lexer.send(o, code_lines_in_method_ruler) }
        end
      end

      def init_trailing_newline_ruler(v_spacing_ruler, lexer)
        if @config[:vertical_spacing][:trailing_newlines]
          trailing_newline_ruler = TrailingNewlineRuler.new(
            @config[:vertical_spacing][:trailing_newlines]
          )
          v_spacing_ruler.add_child_ruler(trailing_newline_ruler)
          lexer.add_file_observer(trailing_newline_ruler)
        end
      end
    end
  end
end
