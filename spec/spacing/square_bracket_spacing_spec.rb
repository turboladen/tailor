require_relative '../spec_helper'
require 'tailor/file_line'

include Tailor

describe Tailor::FileLine, "with square brackets" do
  context "in an Array" do
    context "with 0 elements" do
      it "should be OK with 0 spaces" do
        line = create_file_line "bobo = []", __LINE__
        line.spacing_problems.should == 0
      end

      it "should detect 1 space after [" do
        line = create_file_line "bobo = [ ]", __LINE__
        line.spacing_problems.should == 2 # 1 after, 1 before
      end
    end

    context "when assigning elements" do
      it "should be OK with 0 spaces" do
        line = create_file_line "bobo = ['clown']", __LINE__
        line.spacing_problems.should == 0
      end

      it "should be OK when beginning of multi-line array" do
        line = create_file_line "  bobo = [", __LINE__
        line.spacing_problems.should == 0
      end

      it "should be OK when end of multi-line array" do
        line = create_file_line "  ]", __LINE__
        line.spacing_problems.should == 0
      end

      it "should detect 1 space after [" do
        line = create_file_line "bobo = [ 'clown']", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 1 space before ]" do
        line = create_file_line "bobo = ['clown' ]", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 1 space after [ and 1 before ]" do
        line = create_file_line "bobo = [ 'clown' ]", __LINE__
        line.spacing_problems.should == 2
      end
    end

    context "when referencing elements" do
      it "should be OK with 0 spaces" do
        line = create_file_line "bobo['clown']", __LINE__
        line.spacing_problems.should == 0
      end

      it "should detect 1 space after [" do
        line = create_file_line "bobo[ 'clown']", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 1 space before [" do
        line = create_file_line "bobo ['clown']", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 1 space before ]" do
        line = create_file_line "bobo['clown' ]", __LINE__
        line.spacing_problems.should == 1
      end

      it "should detect 1 space after [ and 1 before ]" do
        line = create_file_line "bobo[ 'clown' ]", __LINE__
        line.spacing_problems.should == 2
      end

      it "should detect 1 space before and after [ and 1 before ]" do
        line = create_file_line "bobo [ 'clown' ]", __LINE__
        line.spacing_problems.should == 2
      end
    end
  end

  context "in Hash references" do
    it "should be OK with 0 spaces" do
      line = create_file_line "bobo[:clown]", __LINE__
      line.spacing_problems.should == 0
    end

    it "should detect 1 space after [" do
      line = create_file_line "bobo[ :clown]", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 1 space before [" do
      line = create_file_line "bobo [:clown]", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 1 space before ]" do
      line = create_file_line "bobo[:clown ]", __LINE__
      line.spacing_problems.should == 1
    end

    it "should detect 1 space after [ and 1 before ]" do
      line = create_file_line "bobo[ :clown ]", __LINE__
      line.spacing_problems.should == 2
    end

    it "should detect 1 space before and after [ and 1 before ]" do
      line = create_file_line "bobo [ :clown ]", __LINE__
      line.spacing_problems.should == 2
    end
  end
end
