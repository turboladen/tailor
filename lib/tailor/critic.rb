require 'erb'
require 'yaml'
require 'fileutils'
require_relative 'runtime_error'
require_relative 'logger'
require_relative 'lexer'
require_relative 'configuration'
require_relative 'ruler'
require_relative 'rulers'


class Tailor
  class Critic
    include LogSwitch::Mixin
    include Tailor::Rulers

    def initialize(configuration)
      @config = configuration
    end

    # Adds problems found from Lexing to the {problems} list.
    #
    # @param [String] file The file to open, read, and check.
    # @return [Hash] The Problems for that file.
    def check_file file
      log "<#{self.class}> Checking style of a single file: #{file}."
      lexer = Tailor::Lexer.new(file)

      ruler = Ruler.new
      h_spacing_ruler = HorizontalSpacingRuler.
        new(@config[:horizontal_spacing])
      v_spacing_ruler = VerticalSpacingRuler.new(@config[:vertical_spacing])
      names_ruler = NamesRuler.new(@config[:names])

      ruler.add_child_ruler(h_spacing_ruler)
      ruler.add_child_ruler(v_spacing_ruler)
      ruler.add_child_ruler(names_ruler)

      if @config[:horizontal_spacing]
        unless @config[:horizontal_spacing][:allow_hard_tabs]
          hard_tab_ruler = HardTabRuler.new
          h_spacing_ruler.add_child_ruler(hard_tab_ruler)
          lexer.add_sp_observer(hard_tab_ruler)
        end

        unless @config[:horizontal_spacing][:allow_trailing_spaces]
          trailing_line_space_ruler = TrailingLineSpaceRuler.new
          h_spacing_ruler.add_child_ruler(trailing_line_space_ruler)
          lexer.add_ignored_nl_observer(trailing_line_space_ruler)
          lexer.add_nl_observer(trailing_line_space_ruler)
        end

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

        if @config[:horizontal_spacing][:line_length]
          line_length_ruler = LineLengthRuler.new(
            @config[:horizontal_spacing][:line_length]
          )
          h_spacing_ruler.add_child_ruler(line_length_ruler)
          lexer.add_ignored_nl_observer(line_length_ruler)
          lexer.add_nl_observer(line_length_ruler)
        end

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

      if @config[:vertical_spacing]
        if @config[:vertical_spacing][:trailing_newlines]
          trailing_newline_ruler = TrailingNewlineRuler.new(
            @config[:vertical_spacing][:trailing_newlines]
          )
          v_spacing_ruler.add_child_ruler(trailing_newline_ruler)
          lexer.add_file_observer(trailing_newline_ruler)
        end
      end

      if @config[:names]
        unless @config[:names][:allow_camel_case_methods]
          camel_case_method_ruler = CamelCaseMethodRuler.new
          names_ruler.add_child_ruler(camel_case_method_ruler)
          lexer.add_ident_observer(camel_case_method_ruler)
        end

        unless @config[:names][:allow_screaming_snake_case_classes]
          screaming_snake_case_class_ruler = ScreamingSnakeCaseClassRuler.new
          names_ruler.add_child_ruler(screaming_snake_case_class_ruler)
          lexer.add_const_observer(screaming_snake_case_class_ruler)
        end
      end

      lexer.lex
      lexer.check_added_newline

      problems[file] = ruler.problems

      { file => problems[file] }
    end

    # @todo This could delegate to Ruport (or something similar) for allowing
    #   output of different types.
    def print_report
      if problems.empty?
        puts "Your files are in style."
      else
        summary_table = Text::Table.new
        summary_table.head = [{ value: "Tailor Summary", colspan: 2 }]
        summary_table.rows << [{ value: "File", align: :center },
          { value: "Total Problems", align: :center }]
        summary_table.rows << :separator

        problems.each do |file, problem_list|
          unless problem_list.empty?
            print_file_problems(file, problem_list)
          end

          summary_table.rows << [file, problem_list.size]
        end

        puts summary_table
      end
    end

    # @return [Hash]
    def problems
      @problems ||= {}
    end

    # @return [Fixnum] The number of problems found so far.
    def problem_count
      problems.values.flatten.size
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
