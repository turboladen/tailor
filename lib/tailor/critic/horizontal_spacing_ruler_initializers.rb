require_relative '../rulers'

class Tailor
  class Critic
    module HorizontalSpacingRulerInitializers
      include Tailor::Rulers

      def init_horizontal_spacing_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing]
          init_hard_tab_ruler(h_spacing_ruler, lexer)
          init_trailing_line_space_ruler(h_spacing_ruler, lexer)
          init_indentation_ruler(h_spacing_ruler, lexer)
          init_line_length_ruler(h_spacing_ruler, lexer)
          init_spaces_after_comma_ruler(h_spacing_ruler, lexer)
          init_spaces_before_comma_ruler(h_spacing_ruler, lexer)
          init_spaces_before_lbrace_ruler(h_spacing_ruler, lexer)
          init_spaces_after_lbrace_ruler(h_spacing_ruler, lexer)
        end
      end

      def init_spaces_before_lbrace_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing]
          if @config[:horizontal_spacing][:braces]
            if @config[:horizontal_spacing][:braces][:spaces_before_left]
              spaces_before_lbrace_ruler = SpacesBeforeLBraceRuler.new(
                @config[:horizontal_spacing][:braces][:spaces_before_left]
              )
              h_spacing_ruler.add_child_ruler(spaces_before_lbrace_ruler)
              lexer.add_lbrace_observer(spaces_before_lbrace_ruler)
            end
          end
        end
      end

      def init_spaces_after_lbrace_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing]
          if @config[:horizontal_spacing][:braces]
            if @config[:horizontal_spacing][:braces][:spaces_after_left]
              spaces_after_lbrace_ruler = SpacesAfterLBraceRuler.new(
                @config[:horizontal_spacing][:braces][:spaces_after_left]
              )
              h_spacing_ruler.add_child_ruler(spaces_after_lbrace_ruler)
              lexer.add_comment_observer(spaces_after_lbrace_ruler)
              lexer.add_ignored_nl_observer(spaces_after_lbrace_ruler)
              lexer.add_lbrace_observer(spaces_after_lbrace_ruler)
              lexer.add_nl_observer(spaces_after_lbrace_ruler)
            end
          end
        end
      end

      def init_spaces_before_comma_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing][:spaces_before_comma]
          space_before_comma_ruler = SpacesBeforeCommaRuler.new(
            @config[:horizontal_spacing][:spaces_before_comma]
          )
          h_spacing_ruler.add_child_ruler(space_before_comma_ruler)
          lexer.add_comma_observer(space_before_comma_ruler)
          lexer.add_comment_observer(space_before_comma_ruler)
          lexer.add_ignored_nl_observer(space_before_comma_ruler)
          lexer.add_nl_observer(space_before_comma_ruler)
        end
      end

      def init_spaces_after_comma_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing][:spaces_after_comma]
          space_after_comma_ruler = SpacesAfterCommaRuler.new(
            @config[:horizontal_spacing][:spaces_after_comma]
          )
          h_spacing_ruler.add_child_ruler(space_after_comma_ruler)
          lexer.add_comma_observer(space_after_comma_ruler)
          lexer.add_comment_observer(space_after_comma_ruler)
          lexer.add_ignored_nl_observer(space_after_comma_ruler)
          lexer.add_nl_observer(space_after_comma_ruler)
        end
      end

      def init_line_length_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing][:line_length]
          line_length_ruler = LineLengthRuler.new(
            @config[:horizontal_spacing][:line_length]
          )
          h_spacing_ruler.add_child_ruler(line_length_ruler)
          lexer.add_ignored_nl_observer(line_length_ruler)
          lexer.add_nl_observer(line_length_ruler)
        end
      end

      def init_indentation_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing][:indent_spaces]
          indentation_ruler = IndentationRuler.new(
            @config[:horizontal_spacing][:indent_spaces])
          h_spacing_ruler.add_child_ruler(indentation_ruler)
          lexer.add_comma_observer indentation_ruler
          lexer.add_comment_observer indentation_ruler
          lexer.add_embexpr_beg_observer indentation_ruler
          lexer.add_embexpr_end_observer indentation_ruler
          lexer.add_ignored_nl_observer indentation_ruler
          lexer.add_kw_observer indentation_ruler
          lexer.add_lbrace_observer indentation_ruler
          lexer.add_lbracket_observer indentation_ruler
          lexer.add_lparen_observer indentation_ruler
          lexer.add_nl_observer indentation_ruler
          lexer.add_period_observer indentation_ruler
          lexer.add_rbrace_observer indentation_ruler
          lexer.add_rbracket_observer indentation_ruler
          lexer.add_rparen_observer indentation_ruler
          lexer.add_tstring_beg_observer indentation_ruler
          lexer.add_tstring_end_observer indentation_ruler

          indentation_ruler.start
        end
      end

      def init_trailing_line_space_ruler(h_spacing_ruler, lexer)
        unless @config[:horizontal_spacing][:allow_trailing_spaces]
          trailing_line_space_ruler = TrailingLineSpaceRuler.new
          h_spacing_ruler.add_child_ruler(trailing_line_space_ruler)
          lexer.add_ignored_nl_observer(trailing_line_space_ruler)
          lexer.add_nl_observer(trailing_line_space_ruler)
        end
      end

      def init_hard_tab_ruler(h_spacing_ruler, lexer)
        unless @config[:horizontal_spacing][:allow_hard_tabs]
          hard_tab_ruler = HardTabRuler.new
          h_spacing_ruler.add_child_ruler(hard_tab_ruler)
          lexer.add_sp_observer(hard_tab_ruler)
        end
      end
    end
  end
end
