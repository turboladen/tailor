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

  describe "#modifier_keyword?" do
    context "the current line has a keyword that is also a modifier" do
      context "the keyword is acting as a modifier" do
        let!(:file_text) { %q{puts "hi" if true == true} }

        it "returns true" do
          subject.stub(:lineno).and_return 1
          subject.instance_variable_set(:@file_text, file_text)
          subject.modifier_keyword?("if").should be_true
        end
      end

      context "they keyword is NOT acting as a modifier" do
        let!(:file_text) { %q{if true == true; puts "hi"; end} }

        it "returns false" do
          subject.stub(:lineno).and_return 1
          subject.instance_variable_set(:@file_text, file_text)
          subject.modifier_keyword?("if").should be_false
        end
      end
    end

    context "the current line doesn't have a keyword" do
      let!(:file_text) { %q{puts true} }

      it "returns false" do
        subject.stub(:lineno).and_return 1
        subject.instance_variable_set(:@file_text, file_text)
        subject.modifier_keyword?("puts").should be_false
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
end
