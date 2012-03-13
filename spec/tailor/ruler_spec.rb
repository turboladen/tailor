require 'fakefs/spec_helpers'
require_relative '../spec_helper'
require 'tailor/ruler'

describe Tailor::Ruler do
  let!(:file_text) { "" }
  let(:style) { {} }
  let(:indentation_ruler) { double "IndentationRuler" }

  subject { Tailor::Ruler.new(file_text, style) }

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

  describe "#current_lex" do
    let(:lexed_output) do
      [
        [[1, 0], :on_ident, "require"],
          [[1, 7], :on_sp, " "],
          [[1, 8], :on_tstring_beg, "'"],
          [[1, 9], :on_tstring_content, "log_switch"],
          [[1, 19], :on_tstring_end, "'"],
          [[1, 20], :on_nl, "\n"],
          [[2, 0], :on_ident, "require_relative"],
          [[2, 16], :on_sp, " "],
          [[2, 17], :on_tstring_beg, "'"],
          [[2, 18], :on_tstring_content, "tailor/runtime_error"],
          [[2, 38], :on_tstring_end, "'"],
          [[2, 39], :on_nl, "\n"]
      ]
    end

    it "returns all lexed output from line 1 when self.lineno is 1" do
      subject.stub(:lineno).and_return(1)
      subject.current_lex(lexed_output).should == [[[1, 0], :on_ident, "require"],
        [[1, 7], :on_sp, " "],
        [[1, 8], :on_tstring_beg, "'"],
        [[1, 9], :on_tstring_content, "log_switch"],
        [[1, 19], :on_tstring_end, "'"],
        [[1, 20], :on_nl, "\n"]
      ]
    end
  end

  describe "#current_line_indent" do
    subject { Tailor::Ruler.new(file_text, style) }

    context "when indented 0" do
      let(:file_text) { "puts 'something'" }

      it "returns 0" do
        subject.current_line_indent(Ripper.lex(file_text)).should == 0
      end
    end

    context "when indented 1" do
      let(:file_text) { " puts 'something'" }

      it "returns 1" do
        subject.current_line_indent(Ripper.lex(file_text)).should == 1
      end
    end
  end

  describe "#line_of_only_spaces?" do
    context '0 length line, no \n ending' do
      let(:file_text) { "" }

      it "should return true" do
        subject.line_of_only_spaces?(Ripper.lex(file_text)).should be_true
      end
    end

    context '0 length line, with \n ending' do
      let(:file_text) { "\n" }

      it "should return true" do
        subject.line_of_only_spaces?(Ripper.lex(file_text)).should be_true
      end
    end

    context 'comment line, starting at column 0' do
      let(:file_text) { "# this is a comment" }

      it "should return false" do
        subject.line_of_only_spaces?(Ripper.lex(file_text)).should be_false
      end
    end

    context 'comment line, starting at column 2' do
      let(:file_text) { "  # this is a comment" }

      it "should return false" do
        subject.line_of_only_spaces?(Ripper.lex(file_text)).should be_false
      end
    end

    context 'code line, starting at column 2' do
      let(:file_text) { "  class << self" }

      it "should return false" do
        subject.line_of_only_spaces?(Ripper.lex(file_text)).should be_false
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

  describe "#update_outdentation_expectations" do
    context "#single_line_indent_statement? returns false" do
      before do
        subject.stub(:single_line_indent_statement?).and_return false
      end

      it "calls #decrease_this_line" do
        indentation_ruler.should_receive(:decrease_this_line)
        indentation_ruler.stub(:decrease_next_line)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
        subject.update_outdentation_expectations
        indentation_ruler.unstub(:decrease_next_line)
      end
    end

    context "#single_line_indent_statement? returns true" do
      before do
        subject.stub(:single_line_indent_statement?).and_return true
      end

      it "does not call #decrease_this_line" do
        indentation_ruler.should_not_receive(:decrease_this_line)
        indentation_ruler.stub(:decrease_next_line)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
        subject.update_outdentation_expectations
        indentation_ruler.unstub(:decrease_next_line)
      end

      it "calls #decrease_this_line" do
        indentation_ruler.stub(:decrease_this_line)
        indentation_ruler.should_receive(:decrease_next_line)
        subject.instance_variable_set(:@indentation_ruler, indentation_ruler)
        subject.update_outdentation_expectations
        indentation_ruler.unstub(:decrease_this_line)
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

  describe "#line_ends_with_op?" do
    context "line ends with a +, then \\n" do
      let(:lexed_output) do
        [
          [[1, 0], :on_ident, "thing"],
          [[1, 5], :on_sp, " "],
          [[1, 6], :on_op, "="],
          [[1, 7], :on_sp, " "],
          [[1, 8], :on_int, "1"],
          [[1, 9], :on_sp, " "],
          [[1, 10], :on_op, "+"],
          [[1, 11], :on_ignored_nl, "\n"],
          [[1, 11], :on_ignored_nl, "\n"]
        ]
      end

      it "returns true" do
        subject.line_ends_with_op?(lexed_output).should be_true
      end
    end

    context "line ends with not an operator, then \\n" do
      let(:lexed_output) do
        [
          [[1, 0], :on_ident, "thing"],
          [[1, 5], :on_sp, " "],
          [[1, 6], :on_op, "="],
          [[1, 7], :on_sp, " "],
          [[1, 8], :on_int, "1"],
          [[1, 11], :on_nl, "\n"]
        ]
      end

      it "returns false" do
        subject.line_ends_with_op?(lexed_output).should be_false
      end
    end
  end

  describe "#loop_with_do?" do
    context "line is 'while true do\\n'" do
      let(:lexed_output) do
        [[[1, 0], :on_kw, "while"], [[1, 5], :on_sp, " "], [[1, 6], :on_kw, "true"], [[1, 10], :on_sp, " "], [[1, 11], :on_kw, "do"], [[1, 13], :on_ignored_nl, "\n"]]
      end

      it "returns true" do
        subject.loop_with_do?(lexed_output).should be_true
      end
    end

    context "line is 'while true\\n'" do
      let(:lexed_output) do
        [[[1, 0], :on_kw, "while"], [[1, 5], :on_sp, " "], [[1, 6], :on_kw, "true"], [[1, 10], :on_sp, " "], [[1, 11], :on_ignored_nl, "\n"]]
      end

      it "returns false" do
        subject.loop_with_do?(lexed_output).should be_false
      end
    end

    context "line is 'until true do\\n'" do
      let(:lexed_output) do
        [[[1, 0], :on_kw, "until"], [[1, 5], :on_sp, " "], [[1, 6], :on_kw, "true"], [[1, 10], :on_sp, " "], [[1, 11], :on_kw, "do"], [[1, 13], :on_ignored_nl, "\n"]]
      end

      it "returns true" do
        subject.loop_with_do?(lexed_output).should be_true
      end
    end

    context "line is 'until true\\n'" do
      let(:lexed_output) do
        [[[1, 0], :on_kw, "until"], [[1, 5], :on_sp, " "], [[1, 6], :on_kw, "true"], [[1, 10], :on_sp, " "], [[1, 11], :on_ignored_nl, "\n"]]
      end

      it "returns false" do
        subject.loop_with_do?(lexed_output).should be_false
      end
    end

    context "line is 'for i in 1..5 do\\n'" do
      let(:lexed_output) do
        [[[1, 0], :on_kw, "for"], [[1, 3], :on_sp, " "], [[1, 4], :on_ident, "i"], [[1, 5], :on_sp, " "], [[1, 6], :on_kw, "in"], [[1, 8], :on_sp, " "], [[1, 9], :on_int, "1"], [[1, 10], :on_op, ".."], [[1, 12], :on_int, "5"], [[1, 13], :on_sp, " "], [[1, 14], :on_kw, "do"], [[1, 16], :on_ignored_nl, "\n"]]
      end

      it "returns true" do
        subject.loop_with_do?(lexed_output).should be_true
      end
    end

    context "line is 'for i in 1..5\\n'" do
      let(:lexed_output) do
        [[[1, 0], :on_kw, "for"], [[1, 3], :on_sp, " "], [[1, 4], :on_ident, "i"], [[1, 5], :on_sp, " "], [[1, 6], :on_kw, "in"], [[1, 8], :on_sp, " "], [[1, 9], :on_int, "1"], [[1, 10], :on_op, ".."], [[1, 12], :on_int, "5"], [[1, 13], :on_sp, " "], [[1, 14], :on_ignored_nl, "\n"]]
      end

      it "returns false" do
        subject.loop_with_do?(lexed_output).should be_false
      end
    end
  end

  describe "#r_event_with_content?" do
    context ":on_rparen" do
      context "line is '  )'" do
        let(:lexed_output) do
          [[[1, 0], :on_sp, "  "], [[1, 2], :on_rparen, ")"]]
        end

        before do
          subject.stub(:lineno).and_return 1
          subject.stub(:column).and_return 2
        end

        it "returns true" do
          subject.r_event_without_content?(lexed_output).should be_true
        end
      end

      context "line is '  })'" do
        let(:lexed_output) do
          [[[1, 0], :on_sp, "  "], [[1, 2], :on_rbrace, "}"], [[1, 3], :on_rparen, ")"]]
        end

        before do
          subject.stub(:lineno).and_return 1
          subject.stub(:column).and_return 3
        end

        it "returns false" do
          subject.r_event_without_content?(lexed_output).should be_false
        end
      end

      context "line is '  def some_method'" do
        let(:lexed_output) do
          [[[1, 0], :on_kw, "def"], [[1, 3], :on_sp, " "], [[1, 4], :on_ident, "some_method"], [[1, 15], :on_nl, "\n"]]
        end

        before do
          subject.stub(:lineno).and_return 1
          subject.stub(:column).and_return 3
        end

        it "returns false" do
          subject.r_event_without_content?(lexed_output).should be_false
        end
      end
    end
  end

  describe "#first_non_space_element" do
    context "lexed line contains only spaces" do
      let(:lexed_output) { [[[1, 0], :on_sp, "     "]] }

      it "returns nil" do
        subject.first_non_space_element(lexed_output).should be_nil
      end
    end

    context "lexed line contains only \\n" do
      let(:lexed_output) { [[[1, 0], :on_ignored_nl, "\n"]] }

      it "returns nil" do
        subject.first_non_space_element(lexed_output).should be_nil
      end
    end

    context "lexed line contains '  }\\n'" do
      let(:lexed_output) { [[[1, 0], :on_sp, "  "], [[1, 2], :on_rbrace, "}"], [[1, 3], :on_nl, "\n"]] }

      it "returns nil" do
        subject.first_non_space_element(lexed_output).should ==
          [[1,2], :on_rbrace, "}"]
      end
    end
  end
end
