require_relative '../rulers'

class Tailor
  class Critic
    module VerticalSpacingRulerInitializers
      include Tailor::Rulers

      def init_vertical_spacing_ruler(lexer, v_spacing_ruler)
        if @config[:vertical_spacing]
          init_trailing_newline_ruler(lexer, v_spacing_ruler)
        end
      end

      def init_names_ruler(lexer, names_ruler)
        if @config[:names]
          init_camel_case_method_ruler(lexer, names_ruler)
          init_screaming_snake_case_class_ruler(lexer, names_ruler)
        end
      end

      def init_camel_case_method_ruler(lexer, names_ruler)
        unless @config[:names][:allow_camel_case_methods]
          camel_case_method_ruler = CamelCaseMethodRuler.new
          names_ruler.add_child_ruler(camel_case_method_ruler)
          lexer.add_ident_observer(camel_case_method_ruler)
        end
      end

      def init_screaming_snake_case_class_ruler(lexer, names_ruler)
        unless @config[:names][:allow_screaming_snake_case_classes]
          screaming_snake_case_class_ruler = ScreamingSnakeCaseClassRuler.new
          names_ruler.add_child_ruler(screaming_snake_case_class_ruler)
          lexer.add_const_observer(screaming_snake_case_class_ruler)
        end
      end

      def init_trailing_newline_ruler(lexer, v_spacing_ruler)
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
