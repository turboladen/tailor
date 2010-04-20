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
  
  context "should check for camel case when" do
    it "is a method and the method name is camel case" do
      line = FileLine.new "def doSomething"
      line.camel_case_method?.should be_true
    end

    it "is a method and the method name is snake case" do
      line = FileLine.new "def do_something"
      line.camel_case_method?.should be_false
    end

    it "is a class and the class name is camel case" do
      line = FileLine.new "class AClass"
      line.camel_case_class?.should be_true
    end

    it "is a class and the class name is snake case" do
      line = FileLine.new "class A_Class"
      line.camel_case_class?.should be_false
    end
  end
end