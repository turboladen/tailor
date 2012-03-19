require_relative '../spec_helper'
require 'tailor/critic'

describe Tailor::Critic do
  let(:configuration) do

  end

  subject { Tailor::Critic.new(configuration) }

  describe "#check_file" do
    let(:lexer) { double "Ruler" }

    it "lexes the file" do
      lexer.should_receive(:lex)
      lexer.stub(:problems)
      Tailor::Ruler.should_receive(:new).and_return lexer
      subject.stub_chain(:problems, :[]=)
      subject.stub_chain(:problems, :[])

      subject.check_file("this_file.rb")
    end

    it "adds problems for the file to the main list of problems" do
      file_name = 'this_file.rb'
      lexer.stub(:lex)
      lexer.stub(:problems).and_return Array.new
      Tailor::Ruler.stub(:new).and_return lexer
      subject.problems.should_receive(:[]=).with(file_name, [])

      subject.check_file file_name
    end
  end

  describe "#problems" do
    specify { subject.problems.should be_a Hash }
    specify { subject.problems.should be_empty }
  end

  describe "#problem_count" do
    context "#problems is empty" do
      it "returns 0" do
        subject.instance_variable_set(:@problems, {})
        subject.problem_count.should == 0
      end
    end

    context "#problems contains valid values" do
      it "adds the number of each problem together" do
        probs = {
           one: { type: :indentation, line: 1, message: "" },
           two: { type: :indentation, line: 2, message: "" },
           thre: { type: :indentation, line: 27, message: "" }
        }
        subject.instance_variable_set(:@problems, probs)
        subject.problem_count.should == 3
      end
    end
  end

  describe "#checkable?" do
    context "parameter is a file" do
      before { File.stub(:file?).and_return true }
      after { File.unstub(:file?) }
      specify { subject.checkable?("some_file.rb").should be_true }
    end

    context "parameter is a directory" do
      before { File.stub(:directory?).and_return true }
      after { File.unstub(:directory?) }
      specify { subject.checkable?("some_directory").should be_true }
    end

    context "parameter is neither a file nor a directory" do
      before do
        File.stub(:file?).and_return false
        File.stub(:directory?).and_return false
      end

      after do
        File.unstub(:file?)
        File.unstub(:directory?)
      end

      specify { subject.checkable?("some_other_thing").should be_false }
    end
  end
end
