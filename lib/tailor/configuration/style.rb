class Tailor
  class Configuration
    class Style

      # Adds a style property to a Style object.  If you're planning on creating
      # your own {Ruler}, you need to register the property here.
      #
      # Defines a method from +name+ that takes 2 parameters: +value+ and
      # +options+.  +value+ is the value to use for the {Ruler} of the same +name+
      # for checking style. +options+ can include anything that's necessary for
      # style checking.  A +:level+ option key is used to determine the
      # {Tailor::Problem} level:
      # * +:fail+ results in a exit status of 1.
      # * +:warn+ results in an exit status of 0, but gets printed in the
      #   report.
      #
      # Example:
      #   Tailor::Configuration::Style.define_property(:my_style_property)
      #   style = Tailor::Configuration::Style.new
      #   style.my_style_property(100, level: :warn)
      def self.define_property(name)
        define_method(name) do |value, *options|
          options = options.first || { level: :fail }
          instance_variable_set("@#{name}".to_sym, [value, options])
        end
      end

      define_property :allow_camel_case_methods
      define_property :allow_hard_tabs
      define_property :allow_screaming_snake_case_classes
      define_property :allow_trailing_line_spaces
      define_property :indentation_spaces
      define_property :max_code_lines_in_class
      define_property :max_code_lines_in_method
      define_property :max_line_length
      define_property :spaces_after_comma
      define_property :spaces_after_lbrace
      define_property :spaces_after_lbracket
      define_property :spaces_after_lparen
      define_property :spaces_before_comma
      define_property :spaces_before_lbrace
      define_property :spaces_before_rbrace
      define_property :spaces_before_rbracket
      define_property :spaces_before_rparen
      define_property :spaces_in_empty_braces
      define_property :trailing_newlines

      # Sets up default values.
      def initialize
        allow_camel_case_methods(false, level: :fail)
        allow_hard_tabs(false, level: :fail)
        allow_screaming_snake_case_classes(false, level: :fail)
        allow_trailing_line_spaces(false, level: :fail)
        indentation_spaces(2, level: :fail)
        max_code_lines_in_class(300, level: :fail)
        max_code_lines_in_method(30, level: :fail)
        max_line_length(80, level: :fail)
        spaces_after_comma(1, level: :fail)
        spaces_after_lbrace(1, level: :fail)
        spaces_after_lbracket(0, level: :fail)
        spaces_after_lparen(0, level: :fail)
        spaces_before_comma(0, level: :fail)
        spaces_before_lbrace(1, level: :fail)
        spaces_before_rbrace(1, level: :fail)
        spaces_before_rbracket(0, level: :fail)
        spaces_before_rparen(0, level: :fail)
        spaces_in_empty_braces(0, level: :fail)
        trailing_newlines(1, level: :fail)
      end

      # Returns the current style as a Hash.
      #
      # @return [Hash]
      def to_hash
        instance_variables.inject({}) do |result, ivar|
          result[ivar.to_s.sub(/@/, '').to_sym] = instance_variable_get(ivar)

          result
        end
      end
    end
  end
end
