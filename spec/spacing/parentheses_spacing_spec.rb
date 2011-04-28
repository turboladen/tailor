require_relative '../spec_helper'
require 'tailor/file_line'

include Tailor

describe Tailor::FileLine, "spacing around parentheses" do
  context "in a method" do
    it "should be OK with no space before ) and none after (" do
      line = create_file_line "  def do_something(that, this)", __LINE__
      line.spacing_problems.should == 0
    end

    it "should be OK with no parameters" do
      line = create_file_line "  def do_something()", __LINE__
      line.spacing_problems.should == 0
    end

    it "should detect a space after (" do
      line = create_file_line "  def do_something( that, this)", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect a space before )" do
      line = create_file_line "  def do_something(that, this )", __LINE__
      line.spacing_problems.should == 1
    end
  end
end
