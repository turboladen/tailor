require 'spec_helper'
require 'tailor/cli/options'

# Module to use in tests.
module OptionHelpers
  def cli_option(name)
    "--#{name.to_s.gsub('_', '-')}"
  end

  def option_value(name, value)
    options = Tailor::CLI::Options.parse!([cli_option(name), value])
    options.style[name]
  end
end

describe Tailor::CLI::Options do
  include OptionHelpers

  describe '#parse!' do
    [
      :indentation_spaces,
      :max_code_lines_in_class,
      :max_code_lines_in_method,
      :max_line_length,
      :spaces_after_comma,
      :spaces_after_lbrace,
      :spaces_after_lbracket,
      :spaces_after_lparen,
      :spaces_before_comma,
      :spaces_before_lbrace,
      :spaces_before_rbrace,
      :spaces_before_rbracket,
      :spaces_before_rparen,
      :spaces_in_empty_braces,
      :trailing_newlines
    ].each do |o|
      it 'parses a valid numeric argument correct' do
        expect(option_value(o, '1')).to eq 1
      end

      it 'marks the ruler as off if the option is specified as "off"' do
        expect(option_value(o, 'off')).to eq :off
      end

      it 'marks a ruler as off if the option is specified as "false"' do
        expect(option_value(o, 'false')).to eq :off
      end

      it 'raises if the argument is otherwise not an integer' do
        expect do
          option_value(o, 'not-an-integer')
        end.to raise_error(OptionParser::InvalidArgument)
      end
    end
  end
end
