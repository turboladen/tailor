require File.dirname(__FILE__) + '/spec_helper.rb'
require 'tailor/file_line'
require 'pathname'

include Tailor

describe Tailor::FileLine do

  it "should detect the number of trailing whitespace(s)" do
    line = create_file_line "  puts 'This is a line.'  \n", __LINE__
    line.trailing_whitespace_count.should == 2
  end
  
  describe "spacing around commas" do
    context "in a method line" do
      it "should be OK when no commas" do
        line = create_file_line "  def do_something this", __LINE__
        line.spacing_problems.should == 0
      end

      it "should be OK when 0 spaces before and 1 space after a comma" do
        line = create_file_line "  def do_something this, that", __LINE__
        line.spacing_problems.should == 0
      end

      it "should detect 2 spaces after a comma" do
        line = create_file_line "  def do_something this,  that", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces after a comma" do
        line = create_file_line "  def do_something this,that", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 1 space before a comma" do
        line = create_file_line "  def do_something this , that", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 1 space before a comma and 0 spaces after" do
        line = create_file_line "  def do_something this ,that", __LINE__
        line.spacing_problems.should == 2
      end
    end

    context "in a comment line" do
      it "should be OK when no commas" do
        line = create_file_line "  # Comment line", __LINE__
        line.spacing_problems.should == 0
      end

      it "should be OK when 1 space after a comma" do
        line = create_file_line "  # Comment line, and stuff", __LINE__
        line.spacing_problems.should == 0
      end

      it "should detect 2 spaces after a comma" do
        line = create_file_line "  # Comment line,  and stuff", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces after a comma" do
        line = create_file_line "  # Comment line,and stuff", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 1 space before a comma" do
        line = create_file_line "  # Comment line , and stuff", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 1 space before a comma and 0 spaces after" do
        line = create_file_line "  # Comment line ,and stuff", __LINE__
        line.spacing_problems.should == 2
      end

      it "should be OK when 0 spaces after a comma, but end of the line" do
        line = create_file_line "  # This is a comment that,\n", __LINE__
        line.spacing_problems.should == 0
      end

      it "should detect 2 spaces after a comma when at the end of a line" do
        line = create_file_line "  # This is a comment that,  \n", __LINE__
        line.spacing_problems.should == 2 # 1 for 2 spaces, 1 for whitespace
      end
    end
  end
end
