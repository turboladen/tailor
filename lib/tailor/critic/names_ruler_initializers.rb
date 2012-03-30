=begin
require_relative '../rulers'

class Tailor
  class Critic
    module NamesRulerInitializers
      include Tailor::Rulers

      def init_camel_case_method_ruler(names_ruler, lexer)
        unless @config[:names][:allow_camel_case_methods]
          camel_case_method_ruler = AllowCamelCaseMethodRuler.new
          names_ruler.add_child_ruler(camel_case_method_ruler)
          lexer.add_ident_observer(camel_case_method_ruler)
        end
      end

      def init_screaming_snake_case_class_ruler(names_ruler, lexer)
        unless @config[:names][:allow_screaming_snake_case_classes]
          screaming_snake_case_class_ruler = AllowScreamingSnakeCaseClassesRuler.new
          names_ruler.add_child_ruler(screaming_snake_case_class_ruler)
          lexer.add_const_observer(screaming_snake_case_class_ruler)
        end
      end
    end
  end
end
=end
