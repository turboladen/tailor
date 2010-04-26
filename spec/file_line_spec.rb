require File.dirname(__FILE__) + '/spec_helper.rb'
require 'tailor/file_line'
require 'pathname'

include Tailor

describe Tailor::FileLine do
  context "should return the number of leading spaces in a line" do
    it "when the line is not indented" do
      line = FileLine.new("def do_something", Pathname.new(__FILE__), __LINE__)
      line.indented_spaces.should == 0
    end

    it "when the line is indented 1 space" do
      line = FileLine.new(" def do_something", Pathname.new(__FILE__),
        __LINE__)
      line.indented_spaces.should == 1
    end

    it "when the line is indented 1 space and a hard tab" do
      line = FileLine.new(" \tdef do_something", Pathname.new(__FILE__),
        __LINE__)
      line.indented_spaces.should == 1
    end
  end

  context "should check indenting by spaces" do
    it "when the line is indented 1 hard tab" do
      line = FileLine.new("\tdef do_something", Pathname.new(__FILE__),
        __LINE__)
      line.hard_tabbed?.should be_true
    end

    it "when the line is indented with a space and 1 hard tab" do
      line = FileLine.new(" \tdef do_something", Pathname.new(__FILE__),
        __LINE__)
      line.hard_tabbed?.should be_true
    end

    it "when the line is indented with a space" do
      line = FileLine.new(" def do_something", Pathname.new(__FILE__),
        __LINE__)
      line.hard_tabbed?.should be_false
    end

    it "when the line is not indented" do
      line = FileLine.new("def do_something", Pathname.new(__FILE__), __LINE__)
      line.hard_tabbed?.should be_false
    end
  end

  context "should check for camel case methods when" do
    it "the method name is camel case" do
      line = FileLine.new("def doSomething", Pathname.new(__FILE__), __LINE__)
      line.camel_case_method?.should be_true
    end

    it "the method name is snake case" do
      line = FileLine.new("def do_something", Pathname.new(__FILE__), __LINE__)
      line.camel_case_method?.should be_false
    end
  end

  context "should check for snake case classes when" do
    it "the class name is camel case" do
      line = FileLine.new("class AClass", Pathname.new(__FILE__), __LINE__)
      line.snake_case_class?.should be_false
    end

    it "the class name is snake case" do
      line = FileLine.new("class A_Class", Pathname.new(__FILE__), __LINE__)
      line.snake_case_class?.should be_true
    end
  end

  it "should detect the number of trailing whitespace(s)" do
    line = FileLine.new("  puts 'This is a line.'  \n",
      Pathname.new(__FILE__), __LINE__)
    line.trailing_whitespace_count.should == 2
  end

  # TODO: These methods should probably all be called by
  #   line.check_comma_spacingor something.  As it stands, these tests are
  #   going to start to get confusing, plus having one entry point for
  #   checking commas probably makes the most sense.
  context "comma spacing" do
    context "after the comma" do
      it "should detect 2 spaces after a comma" do
        line = FileLine.new("  def do_something this,  that",
          Pathname.new(__FILE__), __LINE__)
        line.more_than_one_space_after_comma?.should be_true
      end

      it "should detect 2 spaces after a comma when at the end of a line" do
        line = FileLine.new("  # This is a comment that,  \n",
          Pathname.new(__FILE__), __LINE__)
        line.more_than_one_space_after_comma?.should be_true
      end

      it "should be OK when 1 space after a comma" do
        line = FileLine.new("  def do_something this, that",
          Pathname.new(__FILE__), __LINE__)
        line.more_than_one_space_after_comma?.should be_false
      end

      it "should be OK when no commas" do
        line = FileLine.new("  def do_something this", Pathname.new(__FILE__),
          __LINE__)
        line.more_than_one_space_after_comma?.should be_false
      end

      it "should detect 0 spaces after a comma" do
        line = FileLine.new("  def do_something this,that",
          Pathname.new(__FILE__), __LINE__)
        line.no_space_after_comma?.should be_true
      end

      it "should be OK when 1 space after a comma" do
        line = FileLine.new("  def do_something this, that",
          Pathname.new(__FILE__), __LINE__)
        line.no_space_after_comma?.should be_false
      end

      it "should be OK when 0 spaces after a comma, but end of the line" do
        line = FileLine.new("  # This is a comment that,\n",
          Pathname.new(__FILE__), __LINE__)
        line.no_space_after_comma?.should be_false
      end
    end

    context "before the comma" do
      it "should detect 1 space before a comma" do
        line = FileLine.new("  def do_something this , that",
          Pathname.new(__FILE__), __LINE__)
        line.space_before_comma?.should be_true
      end

      it "should be OK when 0 spaces before a comma" do
        line = FileLine.new("  def do_something this, that",
          Pathname.new(__FILE__), __LINE__)
        line.space_before_comma?.should be_false
      end

      it "should be OK when no commas" do
        line = FileLine.new("  def do_something that", Pathname.new(__FILE__),
          __LINE__)
        line.space_before_comma?.should be_false
      end
    end
  end

  context "comments" do
    it "should detect a regular full line comment" do
      line = FileLine.new("  # This is a comment.", Pathname.new(__FILE__),
        __LINE__)
      line.comment_line?.should be_true
    end

    it "should skip code that's not a full line comment" do
      line = FileLine.new("  puts 'this is some code.'",
        Pathname.new(__FILE__), __LINE__)
      line.comment_line?.should be_false
    end
  end

  context "line length" do
    it "should detect greater than 80 characters" do
      string_81_chars = '#' * 81
      line = FileLine.new(string_81_chars, Pathname.new(__FILE__), __LINE__)
      line.too_long?.should be_true
    end

    it "should detect greater than 80 spaces" do
      string_81_spaces = ' ' * 81
      line = FileLine.new(string_81_spaces, Pathname.new(__FILE__), __LINE__)
      line.too_long?.should be_true
    end

    it "should be OK with 80 chars" do
      string_80_chars = '#' * 80
      line = FileLine.new(string_80_chars, Pathname.new(__FILE__), __LINE__)
      line.too_long?.should be_false
    end

    it "should be OK with 80 spaces" do
      string_80_spaces  = ' ' * 80
      line = FileLine.new(string_80_spaces, Pathname.new(__FILE__), __LINE__)
      line.too_long?.should be_false
    end
  end
end