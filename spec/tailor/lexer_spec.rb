require 'fakefs/spec_helpers'
require_relative '../spec_helper'
require 'tailor/lexer'

describe Tailor::Lexer do
  let!(:file_text) { "" }
  let(:style) { {} }
  let(:indentation_ruler) { double "IndentationSpacesRuler" }

  subject do
    r = Tailor::Lexer.new(file_text)
    r.instance_variable_set(:@buf, [])
    r.stub(:log)

    r
  end

  before do
    Tailor::Lexer.any_instance.stub(:ensure_trailing_newline).and_return(file_text)
  end

  describe "#initialize" do
    context "name of file is passed in" do
      let(:file_name) { "test" }

      before do
        File.open(file_name, 'w') { |f| f.write "some text" }
      end

      it "opens and reads the file by the name passed in" do
        file = double "File"
        file.should_receive(:read).and_return file_text
        File.should_receive(:open).with("test", 'r').and_return file
        Tailor::Lexer.new(file_name)
      end
    end

    context "text to lex is passed in" do
      let(:text) { "some text" }

      it "doesn't try to open a file" do
        File.should_not_receive(:open)
        Tailor::Lexer.new(text)
      end
    end
  end

  describe "#on_ignored_nl" do
    it "calls #current_line_lex" do
      pending
      subject.stub(:only_spaces?).and_return true
      subject.should_receive(:current_line_lex)
      subject.on_ignored_nl("\n")
    end

    context "#only_spaces? is true" do
      pending
      before { subject.stub(:only_spaces?).and_return true }

      it "does not call #update_actual_indentation" do
        pending
      end
    end
  end

  describe "#on_sp" do
    context "@config says to disallow hard tabs" do
      before do
        config = { horizontal_spacing: { allow_hard_tabs: false } }
        subject.instance_variable_set(:@config, config)
      end

      context "token contains a hard tab" do
        it "adds a new problem to @problems" do
          pending "This behavior moved to indent_sp_ruler--move there."

          subject.instance_variable_set(:@problems, [])

          expect { subject.on_sp("\t") }.
            to change{subject.instance_variable_get(:@problems).size}.
            from(0).to 1
        end
      end

      context "token does not contain a hard tab" do
        it "does not add a new problem to @problems" do
          pending "This behavior moved to indent_sp_ruler--move there."

          subject.instance_variable_set(:@problems, [])

          expect { subject.on_sp("\x20") }.
            to_not change{subject.instance_variable_get(:@problems).size}.
            from(0).to 1
        end
      end
    end

    context "@config says to allow hard tabs" do
      before do
        config = { horizontal_spacing: { allow_hard_tabs: true } }
        subject.instance_variable_set(:@config, config)
      end

      it "does not check the token" do
        token = double "token"
        token.stub(:size)
        token.should_not_receive(:=~)
        subject.on_sp(token)
      end
    end
  end

  describe "#current_line_of_text" do
    before do
      subject.instance_variable_set(:@file_text, file_text)
      subject.stub(:lineno).and_return 1
    end

    context "@file_text is 1 line with 0 \\ns" do
      let(:file_text) { "puts 'code'" }

      it "returns the line" do
        subject.current_line_of_text.should == file_text
      end
    end

    context "@file_text is 1 empty line with 0 \\ns" do
      let(:file_text) { "" }

      it "returns the an empty string" do
        subject.current_line_of_text.should == file_text
      end
    end

    context "@file_text is 1 empty line with 1 \\n" do
      let(:file_text) { "\n" }

      it "returns an empty string" do
        subject.current_line_of_text.should == ""
      end
    end
  end

  describe "#count_trailing_newlines" do
    context "text contains 0 trailing \\n" do
      let(:text) { "text" }
      specify { subject.count_trailing_newlines(text).should be_zero }
    end

    context "text contains 1 trailing \\n" do
      let(:text) { "text\n" }
      specify { subject.count_trailing_newlines(text).should == 1 }
    end
  end

  describe "#ensure_trailing_newline" do
    before do
      Tailor::Lexer.any_instance.unstub(:ensure_trailing_newline)
    end
    
    context "text contains a trailing newline already" do
      let!(:text) { "text\n" }
      
      before do
        subject.stub(:count_trailing_newlines).and_return 1
      end

      it "doesn't alter the text" do
        subject.ensure_trailing_newline(text).should == text
      end
    end

    context "text does not contain a trailing newline" do
      let!(:text) { "text" }

      it "adds a newline at the end" do
        subject.ensure_trailing_newline(text).should == text + "\n"
      end
    end
  end
end
