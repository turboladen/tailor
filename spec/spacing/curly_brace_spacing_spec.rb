require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'tailor/file_line'

include Tailor

describe Tailor::FileLine, "with curly braces" do
  context "#no_space_before?" do
    it "should detect 0 spaces around a {" do
      line = create_file_line " 5.times{|num| puts num }", __LINE__
      line.no_space_before?('{').should be_true
    end

    it "should detect 0 spaces around a }" do
      line = create_file_line " 5.times { |num| puts num}", __LINE__
      line.no_space_before?('}').should be_true
    end

    it "should detect 0 spaces before a {" do
      line = create_file_line " 5.times{ |num| puts num }", __LINE__
      line.no_space_before?('{').should be_true
    end

    it "should detect 0 spaces before a }" do
      line = create_file_line " 5.times { |num| puts num}", __LINE__
      line.no_space_before?('}').should be_true
    end

    it "should be OK with 1 space before a { but 0 spaces after" do
      line = create_file_line " 5.times {|num| puts num }", __LINE__
      line.no_space_before?('{').should be_false
    end

    it "should be OK with 1 space before a } but 0 spaces after" do
      line = create_file_line " 5.times { |num| puts num }", __LINE__
      line.no_space_before?('}').should be_false
    end

    it "should be OK with 1 space around a {" do
      line = create_file_line " 5.times { |num| puts num }", __LINE__
      line.no_space_before?('{').should be_false
    end

    it "should be OK with 1 space around a }" do
      line = create_file_line " 5.times { |num| puts num } ", __LINE__
      line.no_space_before?('}').should be_false
    end
  end

  context "#no_space_after?" do
    it "should detect 0 spaces around a {" do
      line = create_file_line " 5.times{|num| puts num }", __LINE__
      line.no_space_after?('{').should be_true
    end

    it "should detect 0 spaces around a }" do
      line = create_file_line " 5.times { |num| puts num}", __LINE__
      line.no_space_after?('}').should be_true
    end

    it "should detect 0 spaces after a {" do
      line = create_file_line " 5.times {|num| puts num }", __LINE__
      line.no_space_after?('{').should be_true
    end

    it "should detect 0 spaces after a }" do
      line = create_file_line " 5.times { |num| puts num }", __LINE__
      line.no_space_after?('}').should be_true
    end

    it "should be OK with 1 space after a { but 0 spaces before" do
      line = create_file_line " 5.times{ |num| puts num }", __LINE__
      line.no_space_after?('{').should be_false
    end

    it "should be OK with 1 space after a } but 0 spaces before" do
      line = create_file_line " 5.times{ |num| puts num} ", __LINE__
      line.no_space_after?('}').should be_false
    end

    it "should be OK with 1 space around a {" do
      line = create_file_line " 5.times { |num| puts num }", __LINE__
      line.no_space_after?('{').should be_false
    end

    it "should be OK with 1 space around a }" do
      line = create_file_line " 5.times { |num| puts num } ", __LINE__
      line.no_space_after?('}').should be_false
    end
  end

  context "#spaces_after?" do
    it "should detect 0 spaces on the right side of a {" do
      line = create_file_line " 5.times {|num| puts num }", __LINE__
      line.spaces_after('{').first.should == 0
    end
  end
end