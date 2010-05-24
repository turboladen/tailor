require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'tailor/file_line'

include Tailor

describe Tailor::FileLine, "with curly braces" do
  context "as a block" do
    it "should be OK with 1 space before, 1 after {, 1 before }" do
      line = create_file_line "  5.times { |num| puts num }", __LINE__
      line.spacing_problems.should == 0
    end

    it "should detect 0 spaces before a {" do
      line = create_file_line "  5.times{ |num| puts num }", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 0 spaces after a {" do
      line = create_file_line "  5.times {|num| puts num }", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 0 spaces before and after a {" do
      line = create_file_line "  5.times{|num| puts num }", __LINE__
      line.spacing_problems.should == 1
    end

    it "should be OK with 1 space around a }" do
      line = create_file_line "  5.times { |num| puts num } ", __LINE__
      line.spacing_problems.should == 1 # Trailing whitespace
    end

    it "should detect 0 spaces before a }" do
      line = create_file_line "  5.times { |num| puts num}", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 0 spaces before & after {, before a }" do
      line = create_file_line "  5.times{|num| puts num}", __LINE__
      line.spacing_problems.should == 2
    end

    it "should detect >1 space after a {" do
      line = create_file_line " 5.times {  |num| puts num }", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect >1 space before a {" do
      line = create_file_line " 5.times  { |num| puts num }", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect >1 space before, no spaces after a {" do
      line = create_file_line " 5.times  {|num| puts num }", __LINE__
      line.spacing_problems.should == 2
    end

    it "should detect >1 space after, no spaces before a {" do
      line = create_file_line " 5.times{  |num| puts num }", __LINE__
      line.spacing_problems.should == 2
    end

    it "should detect >1 space before }" do
      line = create_file_line " 5.times { |num| puts num  }", __LINE__
      line.spacing_problems.should == 1
    end
  end

  context "in Hashes" do
    context "with symbol keys" do
      it "should be OK when declaring a new Hash" do
        line = create_file_line "  thing = {}", __LINE__
        line.spacing_problems.should == 0
      end

      it "should be OK with 1 space before, 1 after {, 1 before }" do
        line = create_file_line "  thing = { :one => 1 }", __LINE__
        line.spacing_problems.should == 0
      end

      it "should be OK with proper spacing and a space at the end" do
        line = create_file_line "  thing = { :one => 1 } ", __LINE__
        line.spacing_problems.should == 1  # Trailing whitespace
      end

      it "should detect 0 spaces after {" do
        line = create_file_line "  thing = {:one => 1 }", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces before {" do
        line = create_file_line "  thing ={ :one => 1 }", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces before and after {" do
        line = create_file_line "  thing ={:one => 1 }", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces before }" do
        line = create_file_line "  thing = { :one => 1}", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces before and after { and }" do
        line = create_file_line "  thing ={:one => 1}", __LINE__
        line.spacing_problems.should == 2
      end
    end

    context "with single-quote string keys" do
      it "should be OK with 1 space before, 1 after {, 1 before }" do
        line = create_file_line "  thing = { 'one' => 1 }", __LINE__
        line.spacing_problems.should == 0
      end

      it "should be OK with proper spacing and a space at the end" do
        line = create_file_line "  thing = { 'one' => 1 } ", __LINE__
        line.spacing_problems.should == 1  # Trailing whitespace
      end

      it "should detect 0 spaces after {" do
        line = create_file_line "  thing = {'one' => 1 }", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces before {" do
        line = create_file_line "  thing ={ 'one' => 1 }", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces before and after {" do
        line = create_file_line "  thing ={'one' => 1 }", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces before }" do
        line = create_file_line "  thing = { 'one' => 1}", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces before and after { and }" do
        line = create_file_line "  thing ={'one' => 1}", __LINE__
        line.spacing_problems.should == 2
      end
    end

    context "with double-quote string keys" do
      it "should be OK with 1 space before, 1 after {, 1 before }" do
        line = create_file_line "  thing = { \"one\" => 1 }", __LINE__
        line.spacing_problems.should == 0
      end

      it "should be OK with proper spacing and a space at the end" do
        line = create_file_line "  thing = { \"one\" => 1 } ", __LINE__
        line.spacing_problems.should == 1  # Trailing whitespace
      end

      it "should detect 0 spaces after {" do
        line = create_file_line "  thing = {\"one\" => 1 }", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces before {" do
        line = create_file_line "  thing ={ \"one\" => 1 }", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces before and after {" do
        line = create_file_line "  thing ={\"one\" => 1 }", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces before }" do
        line = create_file_line "  thing = { \"one\" => 1}", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 0 spaces before and after { and }" do
        line = create_file_line "  thing ={\"one\" => 1}", __LINE__
        line.spacing_problems.should == 2
      end
    end
  end

  context "in Strings" do
    it "should be OK when substituting a variable" do
      thing = ""
      line = create_file_line "  a_string = \"This is a #{thing}\"", __LINE__
      line.spacing_problems.should == 0
    end

    it "should be OK when substituting a method call" do
      line = create_file_line "  a_string = \"This has #{Class.methods}\"", __LINE__
      line.spacing_problems.should == 0
    end
  end

  it "should be OK when used as default params in a method definition" do
    thing = ""
    line = create_file_line "  def a_method one={}", __LINE__
    line.spacing_problems.should == 0
  end
end