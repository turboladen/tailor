require 'ripper'
require_relative './ast_xml'

class Tailor
  module Rulers
    class IndentationSpacesRuler < Tailor::Ruler

      # Determines whether a line is a continuation of previous lines. For ease
      # of implementation we use the s-exp support in Ripper, rather than trying
      # to work it out solely from the token events on the ruler.
      class LineContinuations

        include AstXml

        def initialize(file_name)
          @ast = build_xml(Ripper::SexpBuilder.new(File.read(file_name)).parse)
        end

        # Is the specified line actually a previous line continuing?
        def line_is_continuation?(lineno)
          @continuations ||= begin
            statements = @ast.xpath('//stmts_add/*[
              preceding-sibling::stmts_new | preceding-sibling::stmts_add]')
            statements.reject do |stmt|
              s = stmt.xpath('ancestor::stmts_add').size
              stmt.xpath("descendant::pos[count(ancestor::stmts_add) = #{s}]/
                @line").map { |s| s.to_s.to_i }.uniq.size < 2
            end.reject { |stmt| stmt.name == 'case' }.map do |stmt|
              lines_nesting = lines_with_nesting_level(stmt)
              lines_nesting.shift
              min_level = lines_nesting.values.min
              lines_nesting.reject { |_, n| n > min_level }.keys
            end.flatten
          end

          @continuations.include?(lineno)
        end

        # Are there statements further nested below this line?
        def line_has_nested_statements?(lineno)
          @ast.xpath("//pos[@line='#{lineno}']/
            ancestor::*[parent::stmts_add][1]/
            descendant::stmts_add[descendant::pos[@line > #{lineno}]]").any?
        end

        private

        # Returns a hash of line numbers => nesting level
        def lines_with_nesting_level(node)
          Hash[node.xpath('descendant::pos/@line').map do |ln|
            [ln.to_s.to_i, ln.xpath('count(ancestor::stmts_add)').to_i]
          end.sort.uniq]
        end

      end
    end
  end
end
