require_relative '../rulers'

class Tailor
  class Critic
    module HorizontalSpacingRulerInitializers
      include Tailor::Rulers

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
              [
                :add_comment_observer,
                :add_ignored_nl_observer,
                :add_lbrace_observer,
                :add_nl_observer
              ].each { |o| lexer.send(o, spaces_after_lbrace_ruler)}
            end
          end
        end
      end

      def init_spaces_before_rbrace_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing]
          if @config[:horizontal_spacing][:braces]
            if @config[:horizontal_spacing][:braces][:spaces_before_right]
              spaces_before_rbrace_ruler = SpacesBeforeRBraceRuler.new(
                @config[:horizontal_spacing][:braces][:spaces_before_right]
              )
              h_spacing_ruler.add_child_ruler(spaces_before_rbrace_ruler)
              [
                :add_embexpr_beg_observer,
                :add_lbrace_observer,
                :add_rbrace_observer
              ].each { |o| lexer.send(o, spaces_before_rbrace_ruler)}
            end
          end
        end
      end

      def init_spaces_after_lbracket_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing]
          if @config[:horizontal_spacing][:brackets]
            if @config[:horizontal_spacing][:brackets][:spaces_after_left]
              spaces_after_lbracket_ruler = SpacesAfterLBracketRuler.new(
                @config[:horizontal_spacing][:brackets][:spaces_after_left]
              )
              h_spacing_ruler.add_child_ruler(spaces_after_lbracket_ruler)
              [
                :add_comment_observer,
                :add_ignored_nl_observer,
                :add_lbracket_observer,
                :add_nl_observer
              ].each { |o| lexer.send(o, spaces_after_lbracket_ruler)}
            end
          end
        end
      end

      def init_spaces_in_empty_braces_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing]
          if @config[:horizontal_spacing][:braces]
            if @config[:horizontal_spacing][:braces][:spaces_when_empty]
              spaces_in_empty_braces_ruler = SpacesInEmptyBracesRuler.new(
                @config[:horizontal_spacing][:braces][:spaces_when_empty]
              )
              h_spacing_ruler.add_child_ruler(spaces_in_empty_braces_ruler)
              [
                :add_embexpr_beg_observer,
                :add_lbrace_observer,
                :add_rbrace_observer
              ].each { |o| lexer.send(o, spaces_in_empty_braces_ruler) }
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
          [
            :add_comma_observer,
            :add_comment_observer,
            :add_ignored_nl_observer,
            :add_nl_observer
          ].each { |o| lexer.send(o, space_before_comma_ruler) }
        end
      end

      def init_spaces_after_comma_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing][:spaces_after_comma]
          space_after_comma_ruler = SpacesAfterCommaRuler.new(
            @config[:horizontal_spacing][:spaces_after_comma]
          )
          h_spacing_ruler.add_child_ruler(space_after_comma_ruler)
          [
            :add_comma_observer,
            :add_comment_observer,
            :add_ignored_nl_observer,
            :add_nl_observer
          ].each { |o| lexer.send(o, space_after_comma_ruler) }
        end
      end

      def init_line_length_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing][:line_length]
          line_length_ruler = LineLengthRuler.new(
            @config[:horizontal_spacing][:line_length]
          )
          h_spacing_ruler.add_child_ruler(line_length_ruler)
          [
            :add_ignored_nl_observer,
            :add_nl_observer
          ].each { |o| lexer.send(o, line_length_ruler) }
        end
      end

      def init_indentation_ruler(h_spacing_ruler, lexer)
        if @config[:horizontal_spacing][:indent_spaces]
          indentation_ruler = IndentationRuler.new(
            @config[:horizontal_spacing][:indent_spaces])
          h_spacing_ruler.add_child_ruler(indentation_ruler)
          [
            :add_comma_observer,
            :add_comment_observer,
            :add_embexpr_beg_observer,
            :add_embexpr_end_observer,
            :add_ignored_nl_observer,
            :add_kw_observer,
            :add_lbrace_observer,
            :add_lbracket_observer,
            :add_lparen_observer,
            :add_nl_observer,
            :add_period_observer,
            :add_rbrace_observer,
            :add_rbracket_observer,
            :add_rparen_observer,
            :add_tstring_beg_observer,
            :add_tstring_end_observer
          ].each { |o| lexer.send(o, line_length_ruler) }

          indentation_ruler.start
        end
      end

      def init_trailing_line_space_ruler(h_spacing_ruler, lexer)
        unless @config[:horizontal_spacing][:allow_trailing_spaces]
          trailing_line_space_ruler = TrailingLineSpaceRuler.new
          h_spacing_ruler.add_child_ruler(trailing_line_space_ruler)
          [
            :add_ignored_nl_observer,
            :add_nl_observer
          ].each { |o| lexer.send(o, line_length_ruler) }
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
