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
  when /\{{1}/
    return '{'
  else
    return '['
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
end