require 'ripper'
require_relative './ast_xml'

class Tailor
  module Rulers
    class IndentationSpacesRuler < Tailor::Ruler

      # Determines whether arguments spread across lines are correctly
      # aligned.
      #
      # Function calls with parentheses could be determined easily from
      # the lexed line only but we need to support calls without parentheses
      # too.
      class ArgumentAlignment

        include AstXml

        def initialize(file_name)
          @ast = build_xml(Ripper::SexpBuilder.new(File.read(file_name)).parse)
          @lex = Ripper.lex(File.read(file_name))
        end

        def expected_column(lineno, should_be_at)
          column = call_column(lineno) || declaration_column(lineno)
          correct_for_literals(lineno, column) || should_be_at
        end

        private

        # sexp column offsets for string literals do not include the quote
        def correct_for_literals(lineno, column)
          tstring_index = @lex.index do |pos, token|
            pos[0] == lineno and pos[1] == column and
              token == :on_tstring_content
          end

          tstring_index ? @lex[tstring_index -1][0][1] : column
        end

        def call_column(lineno)
          [
            first_argument(:command_call, :args_add_block, lineno),
            first_argument(:method_add_arg, :args_add_block, lineno)
          ].compact.min
        end

        def declaration_column(lineno)
          first_argument(:def, :params, lineno)
        end

        def first_argument(parent, child, lineno)
          method_defs = @ast.xpath("//#{parent}")
          method_defs.map do |d|
            d.xpath("descendant::#{child}[descendant::pos[@line = #{lineno}
              ]]/descendant::pos[position() = 1 and @line != #{lineno}]/
              @column").first.to_s.to_i
          end.reject { |c| c == 0 }.min
        end

      end
    end
  end
end
