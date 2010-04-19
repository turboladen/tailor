require File.dirname(__FILE__) + '/spec_helper.rb'
require 'ruby_style_checker/file_line'

include RubyStyleChecker

describe RubyStyleChecker::FileLine do
  context "should return the number of leading spaces in a line" do
    it "when the line is not indented" do
      line = FileLine.new "def do_something"
      line.indented_spaces.should == 0
    end

    it "when the line is indented 1 space" do
      line = FileLine.new " def do_something"
      line.indented_spaces.should == 1
    end

    it "when the line is indented 1 space and a hard tab" do
      line = FileLine.new " \tdef do_something"
      line.indented_spaces.should == 1
    end
  end
  
  context "should check hard tabs" do
    it "when the line is indented 1 hard tab" do
      line = FileLine.new "\tdef do_something"
      line.hard_tabbed?.should be_true
    end

    it "when the line is indented with a space and 1 hard tab" do
      line = FileLine.new " \tdef do_something"
      line.hard_tabbed?.should be_true
    end

    it "when the line is indented with a space" do
      line = FileLine.new " def do_something"
      line.hard_tabbed?.should be_false
    end

    it "when the line is not indented" do
      line = FileLine.new "def do_something"
      line.hard_tabbed?.should be_false
    end
  end
  
  context "should check methods for camel case" do
    it "when the method name is camel case" do
      line = FileLine.new "def doSomething"
      line.camel_case?.should be_true
    end
  end
end