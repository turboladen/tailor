require File.dirname(__FILE__) + '/spec_helper.rb'
require 'tailor/file_line'
require 'pathname'

include Tailor

describe Tailor::FileLine do
  def create_file_line(string, line_number)
    FileLine.new(string, Pathname.new(__FILE__), line_number)
  end
  
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

  context "should check indenting by spaces" do
    it "when the line is indented 1 hard tab" do
      line = create_file_line "\tdef do_something", __LINE__
      line.hard_tabbed?.should be_true
    end

    it "when the line is indented with a space and 1 hard tab" do
      line = create_file_line " \tdef do_something", __LINE__
      line.hard_tabbed?.should be_true
    end

    it "when the line is indented with a space" do
      line = create_file_line " def do_something", __LINE__
      line.hard_tabbed?.should be_false
    end

    it "when the line is not indented" do
      line = create_file_line "def do_something", __LINE__
      line.hard_tabbed?.should be_false
    end
  end

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

  it "should detect the number of trailing whitespace(s)" do
    line = create_file_line "  puts 'This is a line.'  \n", __LINE__
    line.trailing_whitespace_count.should == 2
  end

  describe "with commas" do
    context "after the comma" do
      it "should detect 2 spaces after a comma" do
        line = create_file_line "  def do_something this,  that", __LINE__
        line.more_than_one_space_after_comma?.should be_true
      end

      it "should detect 2 spaces after a comma when at the end of a line" do
        line = create_file_line "  # This is a comment that,  \n", __LINE__
        line.more_than_one_space_after_comma?.should be_true
      end

      it "should be OK when 1 space after a comma" do
        line = create_file_line "  def do_something this, that", __LINE__
        line.more_than_one_space_after_comma?.should be_false
      end

      it "should be OK when no commas" do
        line = create_file_line "  def do_something this", __LINE__
        line.more_than_one_space_after_comma?.should be_false
      end

      it "should detect 0 spaces after a comma" do
        line = create_file_line "  def do_something this,that", __LINE__
        line.no_space_after_comma?.should be_true
      end

      it "should be OK when 1 space after a comma" do
        line = create_file_line "  def do_something this, that", __LINE__
        line.no_space_after_comma?.should be_false
      end

      it "should be OK when 0 spaces after a comma, but end of the line" do
        line = create_file_line "  # This is a comment that,\n", __LINE__
        line.no_space_after_comma?.should be_false
      end
    end

    context "before the comma" do
      it "should detect 1 space before a comma" do
        line = create_file_line "  def do_something this , that", __LINE__
        line.space_before_comma?.should be_true
      end

      it "should be OK when 0 spaces before a comma" do
        line = create_file_line "  def do_something this, that", __LINE__
        line.space_before_comma?.should be_false
      end

      it "should be OK when no commas" do
        line = create_file_line "  def do_something that", __LINE__
        line.space_before_comma?.should be_false
      end
    end
  end

  describe "with operators" do
    Tailor::OPERATORS.each_pair do |op_group, op_values|
      op_values.each do |op|
        it "should detect 0 spaces around a #{op} sign" do
          line = create_file_line "  1#{op}1", __LINE__
          line.no_space_around?(op).should be_true
        end

        it "should detect 0 spaces on the left side of a #{op} sign" do
          line = create_file_line "  1#{op} 1", __LINE__
          line.no_space_around?(op).should be_true
        end

        it "should detect 0 spaces on the right side of a #{op} sign" do
          line = create_file_line "  1 #{op}1", __LINE__
          line.no_space_around?(op).should be_true
        end

        it "should be OK with 1 space on both sides of a #{op} sign" do
          line = create_file_line "  1 #{op} 1", __LINE__
          line.no_space_around?(op).should be_false
        end

        context "#no_space_on_right_side?" do
          it "should detect 0 spaces on the right side of a #{op} sign" do
            line = create_file_line "  1 #{op}1", __LINE__
            line.no_space_on_right_side?(op).should be_true
          end
        end
        
        context "#no_space_on_left_side?" do
          it "should detect 0 spaces on the left side of a #{op} sign" do
            line = create_file_line "  1#{op} 1", __LINE__
            line.no_space_on_left_side?(op).should be_true
          end
        end
      end
    end
  end
  
  describe "with parentheses/brackets" do
    context "open parenthesis" do
      it "should detect a space after" do
        line = create_file_line "  def do_something( that, this)", __LINE__
        line.space_after_open_parenthesis?.should be_true
      end

      it "should be OK with no space after" do
        line = create_file_line "  def do_something(that, this)", __LINE__
        line.space_after_open_parenthesis?.should be_false
      end
    end

    context "closed parenthesis" do
      it "should detect a space before" do
        line = create_file_line "  def do_something(that, this )", __LINE__
        line.space_before_closed_parenthesis?.should be_true
      end

      it "should be OK with no space after" do
        line = create_file_line "  def do_something(that, this)", __LINE__
        line.space_before_closed_parenthesis?.should be_false
      end
    end

    context "open bracket" do
      it "should detect a space after" do
        line = create_file_line "[ that, this]", __LINE__
        line.space_after_open_bracket?.should be_true
      end

      it "should be OK with no space after" do
        line = create_file_line "[that, this]", __LINE__
        line.space_after_open_bracket?.should be_false
      end
    end

    context "closed parenthesis" do
      it "should detect a space before" do
        line = create_file_line "  def do_something(that, this )", __LINE__
        line.space_before_closed_parenthesis?.should be_true
      end

      it "should be OK with no space after" do
        line = create_file_line "  def do_something(that, this)", __LINE__
        line.space_before_closed_parenthesis?.should be_false
      end
    end
  end

  describe "with curly braces" do
    it "should detect 0 spaces around a {" do
      line = create_file_line " 5.times{|num| puts num }", __LINE__
      line.no_space_around?('{').should be_true
    end

    it "should detect 0 spaces on the left side of a {" do
      line = create_file_line " 5.times{ |num| puts num }", __LINE__
      line.no_space_around?('{').should be_true
    end

    it "should detect 0 spaces on the right side of a {" do
      line = create_file_line " 5.times {|num| puts num }", __LINE__
      line.no_space_around?('{').should be_true
    end

    context "#no_space_on_right_side?" do
      it "should detect 0 spaces on the right side of a {" do
        line = create_file_line " 5.times {|num| puts num }", __LINE__
        line.no_space_on_right_side?('{').should be_true
      end
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
