require_relative 'spec_helper'
require 'tailor/file_line'
require 'pathname'

include Tailor

describe Tailor::FileLine do
  
  describe "with method definitions" do
    it "should detect when the method name is camel case" do
      line = create_file_line "def doSomething", __LINE__
      line.camel_case_method?.should be_true
    end

    it "should be OK when the method name is snake case" do
      line = create_file_line "def do_something", __LINE__
      line.camel_case_method?.should be_false
    end
  end

  describe "with class names" do
    it " should be OK when the class name is camel case" do
      line = create_file_line "class AClass", __LINE__
      line.snake_case_class?.should be_false
    end

    it "should dectect the class name is snake case" do
      line = create_file_line "class A_Class", __LINE__
      line.snake_case_class?.should be_true
    end
  end

  describe "with comments" do
    it "should detect a regular full line comment" do
      line = create_file_line "  # This is a comment.", __LINE__
      line.comment_line?.should be_true
    end

    it "should skip code that's not a full line comment" do
      line = create_file_line "  puts 'this is some code.'", __LINE__
      line.comment_line?.should be_false
    end
  end

  context "line length" do
    it "should detect greater than 80 characters" do
      string_81_chars = '#' * 81
      line = create_file_line string_81_chars, __LINE__
      line.too_long?.should be_true
    end

    it "should detect greater than 80 spaces" do
      string_81_spaces = ' ' * 81
      line = create_file_line string_81_spaces, __LINE__
      line.too_long?.should be_true
    end

    it "should be OK with 80 chars" do
      string_80_chars = '#' * 80
      line = create_file_line string_80_chars, __LINE__
      line.too_long?.should be_false
    end

    it "should be OK with 80 spaces" do
      string_80_spaces  = ' ' * 80
      line = create_file_line string_80_spaces, __LINE__
      line.too_long?.should be_false
    end
  end
end
