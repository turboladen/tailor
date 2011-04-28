require_relative '../spec_helper'
require 'tailor/file_line'

include Tailor

describe Tailor::FileLine, "spacing around commas" do
  it "should be OK when followed by a \\ to signify line-continue" do
    line = create_file_line "string = 'One, two, three,'\\", __LINE__
    line.spacing_problems.should == 0
  end

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
      line.spacing_problems.should == 1   # 1 for whitespace
    end

    it "should detect 2 spaces after a comma" do
      line = create_file_line "  # This is a comment that,  meows", __LINE__
      line.spacing_problems.should == 1
    end
  end

  context "in a statement with an Array" do
    it "should be OK when no commas" do
      line = create_file_line "  bobo = ['hi']", __LINE__
      line.spacing_problems.should == 0
    end

    it "should be OK when 1 space after a comma" do
      line = create_file_line "  bobo = ['hi', 'meow']", __LINE__
      line.spacing_problems.should == 0
    end

    it "should detect 2 spaces after a comma" do
      line = create_file_line "  bobo = ['hi',  'meow']", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 0 spaces after a comma" do
      line = create_file_line "  bobo = ['hi','meow']", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 1 space before a comma" do
      line = create_file_line "  bobo = ['hi' , 'meow']", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 1 space before a comma and 0 spaces after" do
      line = create_file_line "  bobo = ['hi' ,'meow']", __LINE__
      line.spacing_problems.should == 2
    end
  end

  context "in a statement with a Hash" do
    it "should be OK when no commas" do
      line = create_file_line "bobo = { :hi => 'meow' }", __LINE__
      line.spacing_problems.should == 0
    end

    it "should be OK when 1 space after a comma" do
      line = create_file_line "bobo = { :hi => 'meow', :bye => 'meow' }",
        __LINE__
      line.spacing_problems.should == 0
    end

    it "should detect 2 spaces after a comma" do
      line = create_file_line "bobo = { :hi => 'meow',  :bye => 'meow' }",
        __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 0 spaces after a comma" do
      line = create_file_line "bobo = { :hi => 'meow',:bye => 'meow' }",
        __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 1 space before a comma" do
      line = create_file_line "bobo = { :hi => 'meow' , :bye => 'meow' }",
        __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 1 space before a comma and 0 spaces after" do
      line = create_file_line "bobo = { :hi => 'meow' ,:bye => 'meow' }",
        __LINE__
      line.spacing_problems.should == 2
    end
  end
end
