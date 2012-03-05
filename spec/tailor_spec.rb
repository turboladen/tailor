require_relative 'spec_helper'
require 'tailor'
require 'fakefs/spec_helpers'

describe Tailor do
  include FakeFS::SpecHelpers

  describe "#problems" do
    specify { Tailor.problems.should be_an Array }
    specify { Tailor.problems.should be_empty }
  end

  describe "#check_style" do
    context "single file" do
      before do
        File.open("file1.rb", 'w') { |f| f.write 'hi' }
      end

      it "calls #check_file" do
        Tailor.should_receive(:check_file).once
        Tailor.check_style("file1.rb")
      end
    end

    context "directory" do
      let(:test_dir) { "test_dir" }

      before do
        Dir.mkdir test_dir
        File.open("#{test_dir}/file1.rb", 'w') { |f| f.write 'hi' }
        File.open("#{test_dir}/file2.rb", 'w') { |f| f.write 'hello' }
      end

      it "calls #check_file for each file in the directory" do
        Tailor.should_receive(:check_file).twice
        Tailor.check_style("test_dir")
      end
    end

    context "not a file or directory" do
      before do
        File.stub(:file?).and_return false
        File.stub(:directory?).and_return false
      end

      after do
        File.unstub(:file?)
        File.unstub(:directory?)
      end

      it "raises a Tailor::RuntimeError" do
        expect { Tailor.check_style("something else") }.to raise_error Tailor::RuntimeError
      end
    end
  end

  describe "#check_file" do
    let(:lexer) { double "LineLexer" }

    it "opens and reads the file" do
      lexer.stub(:lex)
      lexer.stub(:problems)
      Tailor::LineLexer.stub(:new).and_return lexer
      Tailor.stub_chain(:problems, :concat)

      Tailor.check_file("this_file.rb")

      Tailor::LineLexer.unstub(:new)
    end

    it "lexes the file" do
      lexer.should_receive(:lex)
      lexer.stub(:problems)
      Tailor::LineLexer.should_receive(:new).and_return lexer
      Tailor.stub_chain(:problems, :concat)

      Tailor.check_file("this_file.rb")
    end

    it "adds problems for the file to the main list of problems" do
      lexer.stub(:lex)
      lexer.stub(:problems).and_return Array.new
      Tailor::LineLexer.stub(:new).and_return lexer
      Tailor.problems.should_receive(:concat).with([])

      Tailor.check_file("this_file.rb")
    end
  end

  describe "#print_report" do
    pending
  end

  describe "#problems" do
    specify { Tailor.problems.should be_an Array }
  end

  describe "#problem_count" do
    context "#problems is empty" do
      it "returns 0" do
        Tailor.instance_variable_set(:@problems, {})
        Tailor.problem_count.should == 0
      end
    end

    context "#problems contains valid values" do
      it "adds the number of each problem together" do
        probs = [
          { file_name: 'one', type: :indentation, line: 1, message: "" },
          { file_name: 'two', type: :indentation, line: 2, message: "" },
          { file_name: 'three', type: :indentation, line: 27, message: "" }
        ]
        Tailor.instance_variable_set(:@problems, probs)
        Tailor.problem_count.should == 3
      end
    end
  end

  describe "#checkable?" do
    context "parameter is a file" do
      before { File.stub(:file?).and_return true }
      after { File.unstub(:file?) }
      specify { Tailor.checkable?("some_file.rb").should be_true }
    end

    context "parameter is a directory" do
      before { File.stub(:directory?).and_return true }
      after { File.unstub(:directory?) }
      specify { Tailor.checkable?("some_directory").should be_true }
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

      specify { Tailor.checkable?("some_other_thing").should be_false }
    end
  end
end
