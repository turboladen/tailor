require File.dirname(__FILE__) + '/spec_helper.rb'
require 'tailor/file_line'
require 'pathname'

include Tailor

describe Tailor::FileLine do

  it "should detect the number of trailing whitespace(s)" do
    line = create_file_line "  puts 'This is a line.'  \n", __LINE__
    line.trailing_whitespace_count.should == 2
  end
  
=begin
  describe "with operators" do
    Tailor::OPERATORS.each_pair do |op_group, op_values|
      op_values.each do |op|
        context "#no_space_after?" do
          it "should detect 0 spaces around a #{op} sign" do
            line = create_file_line "  1#{op}1", __LINE__
            line.no_space_after?(op).should be_true
          end

          it "should be OK with 0 spaces before but 1 space after a #{op} sign" do
            line = create_file_line "  1#{op} 1", __LINE__
            line.no_space_after?(op).should be_false
          end

          it "should report 0 spaces after a #{op} sign" do
            line = create_file_line "  1 #{op}1", __LINE__
            line.no_space_after?(op).should be_true
          end

          it "should be OK with 1 space around a #{op} sign" do
            line = create_file_line "  1 #{op} 1", __LINE__
            line.no_space_after?(op).should be_false
          end

          it "should be OK an #{op} sign isn't in the string" do
            line = create_file_line "  1 plus 1", __LINE__
            line.no_space_after?(op).should be_false
          end
        end

        context "#spaces_after" do
          it "should report 0 spaces after a #{op} sign" do
            line = create_file_line "  1 #{op}1", __LINE__
            line.spaces_after(op).first.should == 0
          end

          it "should report 1 space after a #{op} sign" do
            line = create_file_line "  1 #{op} 1", __LINE__
            line.spaces_after(op).first.should == 1
          end
        end
        
        context "#no_space_before?" do
          it "should detect 0 spaces around a #{op} sign" do
            line = create_file_line "  1#{op}1", __LINE__
            line.no_space_before?(op).should be_true
          end

          it "should be OK with 0 spaces after but 1 space before a #{op} sign" do
            line = create_file_line "  1 #{op}1", __LINE__
            line.no_space_before?(op).should be_false
          end

          it "should report 0 spaces before a #{op} sign" do
            line = create_file_line "  1#{op} 1", __LINE__
            line.no_space_before?(op).should be_true
          end

          it "should be OK with 1 space around a #{op} sign" do
            line = create_file_line "  1 #{op} 1", __LINE__
            line.no_space_before?(op).should be_false
          end

          it "should be OK an #{op} sign isn't in the string" do
            line = create_file_line "  1 plus 1", __LINE__
            line.no_space_before?(op).should be_false
          end
        end

        context "#spaces_before" do
          it "should report 0 spaces before a #{op} sign" do
            line = create_file_line "  1#{op} 1", __LINE__
            line.spaces_before(op).first.should == 0
          end

          it "should report 1 space before a #{op} sign" do
            line = create_file_line "  1 #{op} 1", __LINE__
            line.spaces_before(op).first.should == 1
          end
        end

        context "#word_is_in_string?" do
          it "should report that the #{op} is in a string" do
            line = create_file_line "'  1 #{op} 1'", __LINE__
            line.word_is_in_string?(op).should be_true
          end

          it "should report that the #{op} is NOT in a string" do
            line = create_file_line "  1 #{op} 1", __LINE__
            line.word_is_in_string?(op).should be_false
          end
        end

        context "#word_is_in_regexp?" do
          it "should report that the #{op} is in a Regexp" do
            line = create_file_line "/\\" + op + "$/", __LINE__
            line.word_is_in_regexp?(op).should be_true
          end

          it "should report that the #{op} is NOT in a Regexp" do
            line = create_file_line "\\" + op + "$", __LINE__
            line.word_is_in_regexp?(op).should be_false
          end
        end
      end
    end

    it "should be OK if the line is a method with a ?" do
      line = create_file_line "  def hungry?", __LINE__
      line.question_mark_method?.should be_true
      line.no_space_before?('?').should be_false
    end

    it "should be OK if the line is a known method with a ?" do
      line = create_file_line "  'string'.include?(thing)", __LINE__
      line.question_mark_method?.should be_true
      line.no_space_before?('?').should be_false
    end
  end
=end
  describe "with parentheses/brackets" do
    context "open parenthesis" do
      it "should detect a space after" do
        line = create_file_line "  def do_something( that, this)", __LINE__
        line.space_after_open_parenthesis?.should be_true
      end

      it "should be OK with no space after" do
        line = create_file_line "  def do_something(that, this)", __LINE__
        line.space_after_open_parenthesis?.should be_false
      end
    end

    context "closed parenthesis" do
      it "should detect a space before" do
        line = create_file_line "  def do_something(that, this )", __LINE__
        line.space_before_closed_parenthesis?.should be_true
      end

      it "should be OK with no space after" do
        line = create_file_line "  def do_something(that, this)", __LINE__
        line.space_before_closed_parenthesis?.should be_false
      end
    end

    context "open bracket" do
      it "should detect a space after" do
        line = create_file_line "[ that, this]", __LINE__
        line.space_after_open_bracket?.should be_true
      end

      it "should be OK with no space after" do
        line = create_file_line "[that, this]", __LINE__
        line.space_after_open_bracket?.should be_false
      end
    end

    context "closed parenthesis" do
      it "should detect a space before" do
        line = create_file_line "  def do_something(that, this )", __LINE__
        line.space_before_closed_parenthesis?.should be_true
      end

      it "should be OK with no space after" do
        line = create_file_line "  def do_something(that, this)", __LINE__
        line.space_before_closed_parenthesis?.should be_false
      end
    end
  end

  describe "with curly braces" do
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

  context "question marks" do
    it "should detect a word with a ?" do
      line = create_file_line "  thing.nil?", __LINE__
      line.question_mark_method?.should be_true
    end

    it "should skip a word without a ?" do
      line = create_file_line "  thing.strip!", __LINE__
      line.question_mark_method?.should be_false
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
