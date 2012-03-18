require 'fakefs/spec_helpers'
require_relative '../spec_helper'
require 'tailor/ruler'

describe Tailor::Ruler do
  let!(:file_text) { "" }
  let(:style) { {} }
  let(:indentation_ruler) { double "IndentationRuler" }

  subject do
    r = Tailor::Ruler.new(file_text, style)
    r.instance_variable_set(:@buf, [])

    r
  end

  before do
    Tailor::Ruler.any_instance.stub(:ensure_trailing_newline).and_return(file_text)
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
        Tailor::Ruler.new(file_name, style)
      end
    end

    context "text to lex is passed in" do
      let(:text) { "some text" }

      it "doesn't try to open a file" do
        File.should_not_receive(:open)
        Tailor::Ruler.new(text, style)
      end
    end
  end

  describe "#on_comma" do
    context "column is the last in the line" do
      let(:lineno) { 5 }
      let(:column) { 10 }

      before do
        subject.stub(:column).and_return(column)
        subject.stub(:lineno).and_return(lineno)
        subject.stub_chain(:current_line_of_text, :length).and_return(column)
      end

      it "sets @indentation_ruler.last_comma_statement_line to lineno" do
        indentation_ruler.should_receive(:last_comma_statement_line=).with lineno
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
        subject.on_comma(',')
      end
    end

    context "column is NOT the last in the line" do
      let(:lineno) { 5 }
      let(:column) { 10 }

      before do
        subject.stub(:column).and_return(column)
        subject.stub(:lineno).and_return(lineno)
        subject.stub_chain(:current_line_of_text, :length).and_return(column - 1)
      end

      it "sets @indentation_ruler.last_comma_statement_line to lineno" do
        indentation_ruler.should_not_receive(:last_comma_statement_line=)
        subject.on_comma(',')
      end
    end
  end

  describe "#on_embexpr_beg" do
    it "sets @embexpr_beg to true" do
      subject.instance_variable_set(:@embexpr_beg, false)
      subject.on_embexpr_beg('#{')
      subject.instance_variable_get(:@embexpr_beg).should be_true
    end
  end


  describe "#on_embexpr_end" do
    it "sets @embexpr_beg to false" do
      subject.instance_variable_set(:@embexpr_beg, true)
      subject.on_embexpr_end('}')
      subject.instance_variable_get(:@embexpr_beg).should be_false
    end
  end

  describe "#on_ignored_nl" do
    it "calls #current_line_lex" do
      pending
      subject.stub(:line_of_only_spaces?).and_return true
      subject.should_receive(:current_line_lex)
      subject.on_ignored_nl("\n")
    end

    context "#line_of_only_spaces? is true" do
      pending
      before { subject.stub(:line_of_only_spaces?).and_return true }

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
          subject.instance_variable_set(:@problems, [])

          expect { subject.on_sp("\t") }.
            to change{subject.instance_variable_get(:@problems).size}.
            from(0).to 1
        end
      end

      context "token does not contain a hard tab" do
        it "does not add a new problem to @problems" do
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

  describe "#update_indentation_expectations" do
    it "sets @indent_keyword_line to lineno" do
      indentation_ruler.stub(:increase_next_line)
      subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
      subject.stub(:lineno).and_return 10
      subject.update_indentation_expectations "def"

      subject.instance_variable_get(:@indent_keyword_line).should == 10
      indentation_ruler.unstub(:increase_next_line)
    end

    context "token is a CONTINUATION_KEYWORDS" do
      before do
        Tailor::Ruler::CONTINUATION_KEYWORDS.stub(:include?).and_return true
      end

      it "calls #decrease_this_line" do
        indentation_ruler.should_receive(:decrease_this_line)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
        subject.update_indentation_expectations "when"
      end
    end

    context "token is not a CONTINUATION_KEYWORDS" do
      before do
        Tailor::Ruler::CONTINUATION_KEYWORDS.stub(:include?).and_return false
      end

      it "calls #increase_this_line" do
        indentation_ruler.should_receive(:increase_next_line)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
        subject.update_indentation_expectations "def"
      end
    end
  end

  describe "#single_line_indent_statement?" do
    context "@indent_keyword_line is nil and lineno is 1" do
      before do
        subject.instance_variable_set(:@indent_keyword_line, nil)
        subject.stub(:lineno).and_return 1
      end

      specify { subject.single_line_indent_statement?.should be_false }
    end

    context "@indent_keyword_line is 1 and lineno is 1" do
      before do
        subject.instance_variable_set(:@indent_keyword_line, 1)
        subject.stub(:lineno).and_return 1
      end

      specify { subject.single_line_indent_statement?.should be_true }
    end

    context "@indent_keyword_line is 2 and lineno is 1" do
      before do
        subject.instance_variable_set(:@indent_keyword_line, 2)
        subject.stub(:lineno).and_return 1
      end

      specify { subject.single_line_indent_statement?.should be_false }
    end

    context "@indent_keyword_line is 1 and lineno is 2" do
      before do
        subject.instance_variable_set(:@indent_keyword_line, 1)
        subject.stub(:lineno).and_return 2
      end

      specify { subject.single_line_indent_statement?.should be_false }
    end
  end

  describe "#multiline_braces?" do
    context "@indentation_ruler.brace_nesting is empty" do
      before do
        indentation_ruler.stub_chain(:brace_nesting, :empty?).and_return(true)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
      end

      specify { subject.multiline_braces?.should be_false }
    end

    context "@indentation_ruler.brace_nesting is 0 and lineno is 0" do
      before do
        indentation_ruler.stub_chain(:brace_nesting, :empty?).and_return(false)
        indentation_ruler.stub_chain(:brace_nesting, :last).and_return(0)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
        subject.stub(:lineno).and_return 0
      end

      specify { subject.multiline_braces?.should be_false }
    end

    context "@indentation_ruler.brace_nesting is 0 and lineno is 1" do
      before do
        indentation_ruler.stub_chain(:brace_nesting, :empty?).and_return(false)
        indentation_ruler.stub_chain(:brace_nesting, :last).and_return(0)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
        subject.stub(:lineno).and_return 1
      end

      specify { subject.multiline_braces?.should be_true }
    end

    context "@indentation_ruler.brace_nesting.last is 1 and lineno is 0" do
      before do
        indentation_ruler.stub_chain(:brace_nesting, :empty?).and_return(false)
        indentation_ruler.stub_chain(:brace_nesting, :last).and_return(1)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
        subject.stub(:lineno).and_return 0
      end

      specify { subject.multiline_braces?.should be_false }
    end
  end

  describe "#multiline_brackets?" do
    context "@indentation_ruler.bracket_nesting is empty" do
      before do
        indentation_ruler.stub_chain(:bracket_nesting, :empty?).and_return(true)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
      end

      specify { subject.multiline_brackets?.should be_false }
    end

    context "@indentation_ruler.bracket_nesting.last is 0 and lineno is 0" do
      before do
        indentation_ruler.stub_chain(:bracket_nesting, :empty?).and_return(false)
        indentation_ruler.stub_chain(:bracket_nesting, :last).and_return(0)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
        subject.stub(:lineno).and_return 0
      end

      specify { subject.multiline_brackets?.should be_false }
    end

    context "@indentation_ruler.bracket_nesting.last is 0 and lineno is 1" do
      before do
        indentation_ruler.stub_chain(:bracket_nesting, :empty?).and_return(false)
        indentation_ruler.stub_chain(:bracket_nesting, :last).and_return(0)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
        subject.stub(:lineno).and_return 1
      end

      specify { subject.multiline_brackets?.should be_true }
    end

    context "@indentation_ruler.bracket_nesting.last is 1 and lineno is 0" do
      before do
        indentation_ruler.stub_chain(:bracket_nesting, :empty?).and_return(false)
        indentation_ruler.stub_chain(:bracket_nesting, :last).and_return(1)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
        subject.stub(:lineno).and_return 0
      end

      specify { subject.multiline_brackets?.should be_false }
    end
  end

  describe "#r_event_with_content?" do
    context ":on_rparen" do
      context "line is '  )'" do
        let(:current_line) do
          l = double "LexedLine"
          l.stub(:first_non_space_element).and_return [[1, 2], :on_rparen, ")"]

          l
        end

        before do
          subject.stub(:lineno).and_return 1
          subject.stub(:column).and_return 2
        end

        it "returns true" do
          subject.r_event_without_content?(current_line).should be_true
        end
      end

      context "line is '  })'" do
        let(:current_line) do
          l = double "LexedLine"
          l.stub(:first_non_space_element).and_return [[1, 2], :on_rbrace, "}"]

          l
        end

        before do
          subject.stub(:lineno).and_return 1
          subject.stub(:column).and_return 3
        end

        it "returns false" do
          subject.r_event_without_content?(current_line).should be_false
        end
      end

      context "line is '  def some_method'" do
        let(:current_line) do
          l = double "LexedLine"
          l.stub(:first_non_space_element).and_return [[1, 0], :on_kw, "def"]

          l
        end

        before do
          subject.stub(:lineno).and_return 1
          subject.stub(:column).and_return 3
        end

        it "returns false" do
          subject.r_event_without_content?(current_line).should be_false
        end
      end
    end
  end
end
