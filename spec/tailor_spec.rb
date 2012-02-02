require_relative 'spec_helper'
require 'tailor'

describe Tailor do
  describe "#problems" do
    specify { Tailor.problems.should be_a Hash }
    specify { Tailor.problems.should be_empty }
  end

  describe "#check_style" do
    context "single file" do
      before { File.stub(:file?).and_return true }
      after { File.unstub(:file?) }

      it "calls #check_file" do
        Tailor.should_receive(:check_file).once
        Tailor.check_style("a_file.rb")
      end
    end

    context "directory" do
      before do
        File.stub(:file?).and_return false
        File.stub(:directory?).and_return true
        Dir.stub(:glob).and_return ['first_file.rb', 'second_file.rb']
      end

      after do
        File.unstub(:file?)
        File.unstub(:directory?)
        Dir.unstub(:glob)
      end

      it "calls #check_file for each file in the directory" do
        Tailor.should_receive(:check_file).twice
        Tailor.check_style("a_directory")
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
    let(:file_contents) { double "file contents" }
    let(:lexer) { double "LineLexer" }

    it "opens and reads the file" do
      file_contents.should_receive(:read)
      File.should_receive(:open).and_return file_contents
      lexer.stub(:lex)
      lexer.stub(:problems)
      Tailor::LineLexer.stub(:new).and_return lexer
      Tailor.stub_chain(:problems, :merge)

      Tailor.check_file("this_file.rb")

      Tailor::LineLexer.unstub(:new)
    end

    it "lexes the file" do
      File.stub_chain(:open, :read).and_return file_contents
      lexer.should_receive(:lex)
      lexer.stub(:problems)
      Tailor::LineLexer.should_receive(:new).with(file_contents).and_return lexer
      Tailor.stub_chain(:problems, :merge)

      Tailor.check_file("this_file.rb")

      File.unstub(:open)
    end

    it "adds problems for the file to the main list of problems" do
      File.stub_chain(:open, :read).and_return file_contents
      lexer.stub(:lex)
      lexer.stub(:problems).and_return Hash.new
      Tailor::LineLexer.stub(:new).and_return lexer
      Tailor.problems.should_receive(:merge).with({})

      Tailor.check_file("this_file.rb")

      File.unstub(:open)
    end
  end

  describe "#print_report" do
    pending
  end

  describe "#problems" do
    specify { Tailor.problems.should be_a Hash }
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
        probs = { "hunger" => 1, "thirst" => 2 }
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
