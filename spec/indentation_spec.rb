require File.dirname(__FILE__) + '/spec_helper.rb'
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
      INDENT_EXPRESSIONS.each do |regexp|
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
      OUTDENT_EXPRESSIONS.each do |regexp|
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
      END_EXPRESSIONS.each do |regexp|
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
    INDENT_EXPRESSIONS.each do |regexp|
      expression = strip_regex(regexp)

      it "should return true if the line contains #{expression}" do
        line = create_file_line "#{expression}", __LINE__
        line.indent?.should be_true
      end
    end
  end

  context "#outdent?" do
    OUTDENT_EXPRESSIONS.each do |regexp|
      expression = strip_regex(regexp)

      it "should return true if the line contains #{expression}" do
        line = create_file_line "#{expression}", __LINE__
        line.outdent?.should be_true
      end
    end
  end

  context "#contains_end?" do
    END_EXPRESSIONS.each do |regexp|
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
end