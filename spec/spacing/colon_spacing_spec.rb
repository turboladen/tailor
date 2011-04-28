require_relative '../spec_helper'
require 'tailor/file_line'

include Tailor

describe Tailor::FileLine, "spacing around colons" do
  context "in ternary statments" do
    it "should be OK with 1 space around colon" do
      line = create_file_line "  bobo = true ? true : false", __LINE__
      line.spacing_problems.should == 0
    end

    it "should detect 0 space after colon" do
      line = create_file_line "  bobo = true ? true :false", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 0 space before colon" do
      line = create_file_line "  bobo = true ? true: false", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 0 space before and after colon" do
      line = create_file_line "  bobo = true ? true:false", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 2 spaces after colon" do
      line = create_file_line "  bobo = true ? true :  false", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 2 spaces before colon" do
      line = create_file_line "  bobo = true ? true  : false", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 2 spaces before and after colon" do
      line = create_file_line "  bobo = true ? true  :  false", __LINE__
      line.spacing_problems.should == 1
    end
  end

  context "in symbols" do
    it "should be OK with 1 space before" do
      line = create_file_line "  bobo = { :thing => :clown }", __LINE__
      line.spacing_problems.should == 0
    end

    it "should be OK when Hash key, method with ? and symbol" do
      line = create_file_line "  bobo[:thing].eql? :clown", __LINE__
      line.spacing_problems.should == 0
    end
  end

  it "should be OK in namespace operators" do
    line = create_file_line "bobo[:thing] == :dog ? bobo[:thing] : Class::String",
      __LINE__
    line.spacing_problems.should == 0
  end

  it "should be OK in Regexp classes" do
    line = create_file_line "bobo[:thing].scan(/[:alpha:]/)", __LINE__
    line.spacing_problems.should == 0
  end

  it "should be OK in setting the global load path" do
    line = create_file_line "$:.unshift File.dirname(__FILE__)", __LINE__
    line.spacing_problems.should == 0
  end
end
