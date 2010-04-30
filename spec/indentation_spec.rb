require File.dirname(__FILE__) + '/spec_helper.rb'
require 'tailor/file_line'
require 'pathname'

include Tailor

describe Tailor::FileLine do
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
end