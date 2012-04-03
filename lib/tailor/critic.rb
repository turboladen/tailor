require 'erb'
require 'yaml'
require 'fileutils'
require_relative 'configuration'
require_relative 'lexer'
require_relative 'logger'
require_relative 'ruler'
require_relative 'rulers'
require_relative 'runtime_error'


class Tailor
  class Critic
    include LogSwitch::Mixin
    include Tailor::Rulers
    
    RULER_OBSERVERS = {
      spaces_before_lbrace: [:add_lbrace_observer],
      spaces_after_lbrace: [
        :add_comment_observer,
        :add_ignored_nl_observer,
        :add_lbrace_observer,
        :add_nl_observer
      ],
      spaces_before_rbrace: [
        :add_embexpr_beg_observer,
        :add_lbrace_observer,
        :add_rbrace_observer
      ],
      spaces_after_lbracket: [
        :add_comment_observer,
        :add_ignored_nl_observer,
        :add_nl_observer
      ],
      spaces_before_rbracket: [:add_rbracket_observer],
      spaces_after_lparen: [
        :add_comment_observer,
        :add_ignored_nl_observer,
        :add_lparen_observer,
        :add_nl_observer
      ],
      spaces_before_rparen: [:add_rparen_observer],
      spaces_in_empty_braces: [
        :add_embexpr_beg_observer,
        :add_lbrace_observer,
        :add_rbrace_observer
      ],
      spaces_before_comma: [
        :add_comma_observer,
        :add_comment_observer,
        :add_ignored_nl_observer,
        :add_nl_observer
      ],
      spaces_after_comma: [
        :add_comma_observer,
        :add_comment_observer,
        :add_ignored_nl_observer,
        :add_nl_observer
      ],
      max_line_length: [:add_ignored_nl_observer, :add_nl_observer],
      indentation_spaces: [
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
      ],
      allow_trailing_line_spaces: [:add_ignored_nl_observer, :add_nl_observer],
      allow_hard_tabs: [:add_sp_observer],
      allow_camel_case_methods: [:add_ident_observer],
      allow_screaming_snake_case_classes: [:add_const_observer],
      max_code_lines_in_class: [
        :add_ignored_nl_observer,
        :add_kw_observer,
        :add_nl_observer
      ],
      max_code_lines_in_method: [
        :add_ignored_nl_observer,
        :add_kw_observer,
        :add_nl_observer
      ],
      trailing_newlines: [:add_file_observer]
    }

    def initialize(configuration)
      @file_sets = configuration
    end

    def critique
      @file_sets.each do |label, file_set|
        log "file_set: #{file_set}"

        file_set[:file_list].each do |file|
          log "file: #{file}"
          problems = check_file(file, file_set[:style])
          yield [problems, label] if block_given?
        end
      end
    end

    def init_rulers(style, lexer, parent_ruler)
      style.each do |ruler_name, value|
        log "Initializing ruler: #{ruler_name}"
        ruler = 
          instance_eval("Tailor::Rulers::#{camelize(ruler_name.to_s)}Ruler.new(#{value})")
        parent_ruler.add_child_ruler(ruler)
        RULER_OBSERVERS[ruler_name].each do |observer|
          lexer.send(observer, ruler)
        end
      end
    end

    # Converts a snake-case String to a camel-case String.
    #
    # @param [String] string The String to convert.
    # @return [String] The converted String.
    def camelize(string)
      string.split(/_/).map { |word| word.capitalize }.join
    end

    # Adds problems found from Lexing to the {problems} list.
    #
    # @param [String] file The file to open, read, and check.
    # @return [Hash] The Problems for that file.
    def check_file(file, style)
      log "<#{self.class}> Checking style of a single file: #{file}."
      lexer = Tailor::Lexer.new(file)
      ruler = Ruler.new
      log "Style: #{style}"
      init_rulers(style, lexer, ruler)

      lexer.lex
      lexer.check_added_newline
      problems[file] = ruler.problems

      { file => problems[file] }
    end

    # @return [Hash]
    def problems
      @problems ||= {}
    end

    # @return [Fixnum] The number of problems found so far.
    def problem_count
      problems.values.flatten.size
    end
  end
end
