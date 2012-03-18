require_relative '../spec_helper'
require 'tailor/lexed_line'

describe Tailor::LexedLine do
  subject { Tailor::LexedLine.new(lexed_output, 1) }

  describe "#initialize" do
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
      line = Tailor::LexedLine.new(lexed_output, 1)

      line.should == [
        [[1, 0], :on_ident, "require"],
        [[1, 7], :on_sp, " "],
        [[1, 8], :on_tstring_beg, "'"],
        [[1, 9], :on_tstring_content, "log_switch"],
        [[1, 19], :on_tstring_end, "'"],
        [[1, 20], :on_nl, "\n"]
      ]
    end
  end

  describe "#line_of_only_spaces?" do
    context '0 length line, no \n ending' do
      let(:lexed_output) { [[[1, 0], :on_sp, "  "]] }

      it "should return true" do
        subject.line_of_only_spaces?.should be_true
      end
    end

    context '0 length line, with \n ending' do
      let(:lexed_output) { [[[1, 0], :on_nl, "\n"]] }

      it "should return true" do
        subject.line_of_only_spaces?.should be_true
      end
    end

    context 'comment line, starting at column 0' do
      let(:lexed_output) { [[[1, 0], :on_comment, "# comment"]] }

      it "should return false" do
        subject.line_of_only_spaces?.should be_false
      end
    end

    context 'comment line, starting at column 2' do
      let(:lexed_output) do
        [
          [[1, 0], :on_sp, "  "],
          [[1, 2], :on_comment, "# comment"]
        ]
      end

      it "should return false" do
        subject.line_of_only_spaces?.should be_false
      end
    end

    context 'code line, starting at column 2' do
      let(:lexed_output) do
        [
          [[1, 0], :on_ident, "puts"],
          [[1, 4], :on_sp, " "],
          [[1, 5], :on_tstring_beg, "'"],
          [[1, 6], :on_tstring_content, "thing"],
          [[1, 11], :on_tstring_end, "'"],
          [[1, 12], :on_nl, "\n"]
        ]
      end

      it "should return false" do
        subject.line_of_only_spaces?.should be_false
      end
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
        subject.line_ends_with_op?.should be_true
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
        subject.line_ends_with_op?.should be_false
      end
    end
  end

  describe "#loop_with_do?" do
    context "line is 'while true do\\n'" do
      let(:lexed_output) do
        [[[1, 0], :on_kw, "while"], [[1, 5], :on_sp, " "], [[1, 6], :on_kw, "true"], [[1, 10], :on_sp, " "], [[1, 11], :on_kw, "do"], [[1, 13], :on_ignored_nl, "\n"]]
      end

      it "returns true" do
        subject.loop_with_do?.should be_true
      end
    end

    context "line is 'while true\\n'" do
      let(:lexed_output) do
        [[[1, 0], :on_kw, "while"], [[1, 5], :on_sp, " "], [[1, 6], :on_kw, "true"], [[1, 10], :on_sp, " "], [[1, 11], :on_ignored_nl, "\n"]]
      end

      it "returns false" do
        subject.loop_with_do?.should be_false
      end
    end

    context "line is 'until true do\\n'" do
      let(:lexed_output) do
        [[[1, 0], :on_kw, "until"], [[1, 5], :on_sp, " "], [[1, 6], :on_kw, "true"], [[1, 10], :on_sp, " "], [[1, 11], :on_kw, "do"], [[1, 13], :on_ignored_nl, "\n"]]
      end

      it "returns true" do
        subject.loop_with_do?.should be_true
      end
    end

    context "line is 'until true\\n'" do
      let(:lexed_output) do
        [[[1, 0], :on_kw, "until"], [[1, 5], :on_sp, " "], [[1, 6], :on_kw, "true"], [[1, 10], :on_sp, " "], [[1, 11], :on_ignored_nl, "\n"]]
      end

      it "returns false" do
        subject.loop_with_do?.should be_false
      end
    end

    context "line is 'for i in 1..5 do\\n'" do
      let(:lexed_output) do
        [[[1, 0], :on_kw, "for"], [[1, 3], :on_sp, " "], [[1, 4], :on_ident, "i"], [[1, 5], :on_sp, " "], [[1, 6], :on_kw, "in"], [[1, 8], :on_sp, " "], [[1, 9], :on_int, "1"], [[1, 10], :on_op, ".."], [[1, 12], :on_int, "5"], [[1, 13], :on_sp, " "], [[1, 14], :on_kw, "do"], [[1, 16], :on_ignored_nl, "\n"]]
      end

      it "returns true" do
        subject.loop_with_do?.should be_true
      end
    end

    context "line is 'for i in 1..5\\n'" do
      let(:lexed_output) do
        [[[1, 0], :on_kw, "for"], [[1, 3], :on_sp, " "], [[1, 4], :on_ident, "i"], [[1, 5], :on_sp, " "], [[1, 6], :on_kw, "in"], [[1, 8], :on_sp, " "], [[1, 9], :on_int, "1"], [[1, 10], :on_op, ".."], [[1, 12], :on_int, "5"], [[1, 13], :on_sp, " "], [[1, 14], :on_ignored_nl, "\n"]]
      end

      it "returns false" do
        subject.loop_with_do?.should be_false
      end
    end
  end

  describe "#first_non_space_element" do
    context "lexed line contains only spaces" do
      let(:lexed_output) { [[[1, 0], :on_sp, "     "]] }

      it "returns nil" do
        subject.first_non_space_element.should be_nil
      end
    end

    context "lexed line contains only \\n" do
      let(:lexed_output) { [[[1, 0], :on_ignored_nl, "\n"]] }

      it "returns nil" do
        subject.first_non_space_element.should be_nil
      end
    end

    context "lexed line contains '  }\\n'" do
      let(:lexed_output) { [[[1, 0], :on_sp, "  "], [[1, 2], :on_rbrace, "}"], [[1, 3], :on_nl, "\n"]] }

      it "returns nil" do
        subject.first_non_space_element.should == [[1,2], :on_rbrace, "}"]
      end
    end
  end
end