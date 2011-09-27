require_relative 'spec_helper'
require 'tailor/file_line'
require 'pathname'

include Tailor

def strip_regex regexp
  original_regexp = regexp.source

  case original_regexp
  when /\\b\w+\\b/
    return original_regexp.gsub!("\\b", '')
  when /\w+{2,}/
    return original_regexp.scan(/\w+{2,}/).first
  when /\\\{\[/
    return '{'
  when /\*\\\}/
    return '}'
  when /\\\[\[/
    return '['
  when /\*\\\]/
    return ']'
  end
end

describe Tailor::Indentation do
  include Tailor::Indentation

  context "should return the number of leading spaces in a line" do
    it "when the line is not indented" do
      line = create_file_line "def do_something", __LINE__
      line.indented_spaces.should == 0
    end

    it "when the line is indented 1 space" do
      line = create_file_line " def do_something", __LINE__
      line.indented_spaces.should == 1
    end

    it "when the line is indented 1 space and a hard tab" do
      line = create_file_line " \tdef do_something", __LINE__
      line.indented_spaces.should == 1
    end
  end

  context "should know what level of indentation a line is at" do
    context "for indent expressions" do
      Tailor::Indentation::INDENT_EXPRESSIONS.each do |regexp|
        expression = strip_regex(regexp)

        it "when the '#{expression }' line is not indented" do
          line = create_file_line "#{expression}", __LINE__
          line.is_at_level.should == 0.0
        end

        it "when the '#{expression}' line is indented only 1 space" do
          line = create_file_line " #{expression}", __LINE__
          line.is_at_level.should == 0.5
        end

        it "when the '#{expression}' line is indented 2 spaces" do
          line = create_file_line "  #{expression}", __LINE__
          line.is_at_level.should == 1.0
        end
      end
    end

    context "for outdent expressions" do
      Tailor::Indentation::OUTDENT_EXPRESSIONS.each do |regexp|
        expression = strip_regex(regexp)

        it "when the '#{expression }' line is not indented" do
          line = create_file_line "#{expression}", __LINE__
          line.is_at_level.should == 0.0
        end

        it "when the '#{expression}' line is indented only 1 space" do
          line = create_file_line " #{expression}", __LINE__
          line.is_at_level.should == 0.5
        end

        it "when the '#{expression}' line is indented 2 spaces" do
          line = create_file_line "  #{expression}", __LINE__
          line.is_at_level.should == 1.0
        end
      end
    end

    context "for end expressions" do
      Tailor::Indentation::END_EXPRESSIONS.each do |regexp|
        expression = strip_regex(regexp)

        it "when the '#{expression }' line is not indented" do
          line = create_file_line "#{expression}", __LINE__
          line.is_at_level.should == 0.0
        end

        it "when the '#{expression}' line is indented only 1 space" do
          line = create_file_line " #{expression}", __LINE__
          line.is_at_level.should == 0.5
        end

        it "when the '#{expression}' line is indented 2 spaces" do
          line = create_file_line "  #{expression}", __LINE__
          line.is_at_level.should == 1.0
        end
      end
    end
  end

  context "#indent?" do
    Tailor::Indentation::INDENT_EXPRESSIONS.each do |regexp|
      expression = strip_regex(regexp)

      it "should return true if the line contains #{expression}" do
        line = create_file_line "#{expression}", __LINE__
        line.indent?.should be_true
      end
    end
  end

  context "#outdent?" do
    Tailor::Indentation::OUTDENT_EXPRESSIONS.each do |regexp|
      expression = strip_regex(regexp)

      it "should return true if the line contains #{expression}" do
        line = create_file_line "#{expression}", __LINE__
        line.outdent?.should be_true
      end
    end
  end

  context "#contains_end?" do
    Tailor::Indentation::END_EXPRESSIONS.each do |regexp|
      expression = strip_regex(regexp)

      it "should return true if the line contains #{expression}" do
        line = create_file_line "#{expression}", __LINE__
        line.contains_end?.should be_true
      end
    end
  end

  context "#at_improper_level?" do
    it "should return true if the line is at the wrong level" do
      proper_level = 1.0
      line = create_file_line "class SomeClass", __LINE__
      line.at_improper_level?(proper_level).should be_true
    end

    it "should return false if the line is at the right level" do
      proper_level = 0.0
      line = create_file_line "class SomeClass", __LINE__
      line.at_improper_level?(proper_level).should be_false
    end
  end

  context "#ends_with_operator?" do
    OPERATORS.each_pair do |op_family, op_values|
      op_values.each do |op|
        it "should return true if the line ends with a #{op}" do
          line = create_file_line "1 #{op}", __LINE__
          line.ends_with_operator?.should be_true
        end

        it "should return true if the line ends with a #{op} plus spaces" do
          line = create_file_line "1 #{op}  ", __LINE__
          line.ends_with_operator?.should be_true
        end

        it "should return true if the line ends with a #{op} plus tabs" do
          line = create_file_line "1 #{op}\t\t", __LINE__
          line.ends_with_operator?.should be_true
        end

        it "should return true if the line only has spaces plus a #{op}" do
          line = create_file_line "    #{op}", __LINE__
          line.ends_with_operator?.should be_true
        end
      end
    end

    it "should return false if the line doesn't contain an operator" do
      line = create_file_line "  def some_method(thing)", __LINE__
      line.ends_with_operator?.should be_false
    end
  end

  context "#ends_with_comma?" do
    it "should return true if it ends with a ," do
      line = create_file_line "  def some_method(thing,", __LINE__
      line.ends_with_comma?.should be_true
    end

    it "should return true if it ends with a , and spaces" do
      line = create_file_line "  def some_method(thing,  ", __LINE__
      line.ends_with_comma?.should be_true
    end

    it "should return true if it ends with a , and tabs" do
      line = create_file_line "  def some_method(thing,\t", __LINE__
      line.ends_with_comma?.should be_true
    end

    it "should return false if it doesn't end with a ," do
      line = create_file_line "  def some_method(thing)", __LINE__
      line.ends_with_comma?.should be_false
    end

    it "should return false if it has a , but doesn't end with one" do
      line = create_file_line "  def some_method(thing, other)", __LINE__
      line.ends_with_comma?.should be_false
    end
  end

  context "#ends_with_backslash?" do
    it "should return true if it ends with a \\" do
      line = create_file_line "  def some_method(thing,\\", __LINE__
      line.ends_with_backslash?.should be_true
    end

    it "should return true if it ends with a \\ and spaces" do
      line = create_file_line "  def some_method(thing,\\  ", __LINE__
      line.ends_with_backslash?.should be_true
    end

    it "should return true if it ends with a \\ and tabs" do
      line = create_file_line "  def some_method(thing,\\\t", __LINE__
      line.ends_with_backslash?.should be_true
    end

    it "should return false if it doesn't end with a \\" do
      line = create_file_line "  def some_method(thing)", __LINE__
      line.ends_with_backslash?.should be_false
    end
  end

  context "#unclosed_parenthesis?" do
    it "should return true if it has a ( but no )" do
      line = create_file_line "  def some_method(thing,", __LINE__
      line.unclosed_parenthesis?.should be_true
    end

    it "should return true if it has a ( but no ) and spaces" do
      line = create_file_line "  def some_method(thing,  ", __LINE__
      line.unclosed_parenthesis?.should be_true
    end

    it "should return true if it has a ( but no ) and tabs" do
      line = create_file_line "  def some_method(thing,\t\t", __LINE__
      line.unclosed_parenthesis?.should be_true
    end

    it "should return false if it has a ( and a )" do
      line = create_file_line "  def some_method(thing)", __LINE__
      line.unclosed_parenthesis?.should be_false
    end
  end
end
