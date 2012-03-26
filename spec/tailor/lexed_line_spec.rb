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

  describe "#only_spaces?" do
    context '0 length line, no \n ending' do
      let(:lexed_output) { [[[1, 0], :on_sp, "  "]] }

      it "should return true" do
        subject.only_spaces?.should be_true
      end
    end

    context '0 length line, with \n ending' do
      let(:lexed_output) { [[[1, 0], :on_nl, "\n"]] }

      it "should return true" do
        subject.only_spaces?.should be_true
      end
    end

    context 'comment line, starting at column 0' do
      let(:lexed_output) { [[[1, 0], :on_comment, "# comment"]] }

      it "should return false" do
        subject.only_spaces?.should be_false
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
        subject.only_spaces?.should be_false
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
        subject.only_spaces?.should be_false
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

  describe "#does_line_end_with" do
    let(:lexed_output) do
      [
        [[1, 0], :on_kw, "def"],
          [[1, 3], :on_sp, " "],
          [[1, 4], :on_ident, "thing"],
          [[1, 9], :on_sp, " "],
          [[1, 10], :on_nl, "\n"]
      ]
    end

    context "line ends with the event" do
      it "returns true" do
        subject.does_line_end_with(:on_sp).should be_true
      end
    end

    context "line does not even with event" do
      it "returns false" do
        subject.does_line_end_with(:on_kw).should be_false
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
        subject.first_non_space_element.should == [[1, 2], :on_rbrace, "}"]
      end
    end
  end

  describe "#event_at" do
    let(:lexed_output) { [[[1, 0], :on_sp, "     "]] }

    context "self contains an event at the given column" do
      it "returns that event" do
        subject.event_at(0).should == lexed_output.first
      end
    end

    context "self does not contain an event at the given column" do
      it "returns nil" do
        subject.event_at(1234).should be_nil
      end
    end
  end

  describe "#event_index" do
    let(:lexed_output) { [[[1, 0], :on_sp, "     "]] }

    context "#event_at returns nil" do
      before { subject.stub(:event_at).and_return nil }
      specify { subject.event_index(1234).should be_nil }
    end

    context "#event_at returns a valid colunn" do
      it "returns the event" do
        subject.event_index(0).should be_zero
      end
    end
  end

  describe "#to_s" do
    let(:lexed_output) do
      [
        [[1, 0], :on_kw, "def"],
          [[1, 3], :on_sp, " "],
          [[1, 4], :on_ident, "thing"],
          [[1, 9], :on_sp, " "],
          [[1, 10], :on_nl, "\n"]
      ]
    end

    it "returns the String made up of self's tokens" do
      subject.to_s.should == "def thing \n"
    end
  end

  describe "#remove_comment_at" do
    context "stuff before comment is an incomplete statement" do
      context "spaces before comment" do
        let(:lexed_output) do
          [
            [[1, 0], :on_kw, "def"],
              [[1, 3], :on_sp, " "],
              [[1, 4], :on_ident, "thing"],
              [[1, 9], :on_sp, " "],
              [[1, 10], :on_ident, "one"],
              [[1, 13], :on_comma, ","],
              [[1, 14], :on_sp, "  "],
              [[1, 16], :on_comment, "# comment\n"]
          ]
        end

        let(:file_text) do
          "def thing one,  # comment\n  two\nend\n"
        end

        it "replaces the comment with an :on_ignored_nl" do
          subject.remove_trailing_comment(file_text).should == [
            [[1, 0], :on_kw, "def"],
              [[1, 3], :on_sp, " "],
              [[1, 4], :on_ident, "thing"],
              [[1, 9], :on_sp, " "],
              [[1, 10], :on_ident, "one"],
              [[1, 13], :on_comma, ","],
              [[1, 14], :on_ignored_nl, "\n"]
          ]
        end
      end
      
      context "no spaces before comment" do
        let(:lexed_output) do
          [
            [[1, 0], :on_kw, "def"],
              [[1, 3], :on_sp, " "],
              [[1, 4], :on_ident, "thing"],
              [[1, 9], :on_sp, " "],
              [[1, 10], :on_ident, "one"],
              [[1, 13], :on_comma, ","],
              [[1, 14], :on_comment, "# comment\n"]
          ]
        end

        let(:file_text) do
          "def thing one,# comment\n  two\nend\n"
        end

        it "replaces the comment with an :on_ignored_nl" do
          subject.remove_trailing_comment(file_text).should == [
            [[1, 0], :on_kw, "def"],
              [[1, 3], :on_sp, " "],
              [[1, 4], :on_ident, "thing"],
              [[1, 9], :on_sp, " "],
              [[1, 10], :on_ident, "one"],
              [[1, 13], :on_comma, ","],
              [[1, 14], :on_ignored_nl, "\n"]
          ]
        end
      end
    end
    
    context "stuff before comment is a complete statement" do
      context "spaces before comment" do
        let(:lexed_output) do
          [
            [[1, 0], :on_kw, "def"],
              [[1, 3], :on_sp, " "],
              [[1, 4], :on_ident, "thing"],
              [[1, 9], :on_sp, " "],
              [[1, 10], :on_ident, "one"],
              [[1, 13], :on_sp, "  "],
              [[1, 15], :on_comment, "# comment\n"]
          ]
        end

        let(:file_text) do
          "def thing one  # comment\n\nend\n"
        end

        it "replaces the comment with an :on_nl" do
          subject.remove_trailing_comment(file_text).should == [
            [[1, 0], :on_kw, "def"],
              [[1, 3], :on_sp, " "],
              [[1, 4], :on_ident, "thing"],
              [[1, 9], :on_sp, " "],
              [[1, 10], :on_ident, "one"],
              [[1, 13], :on_nl, "\n"]
          ]
        end
      end

      context "no spaces before comment" do
        let(:lexed_output) do
          [
            [[1, 0], :on_kw, "def"],
              [[1, 3], :on_sp, " "],
              [[1, 4], :on_ident, "thing"],
              [[1, 9], :on_sp, " "],
              [[1, 10], :on_ident, "one"],
              [[1, 13], :on_comment, "# comment\n"]
          ]
        end

        let(:file_text) do
          "def thing one# comment\n  \nend\n"
        end

        it "replaces the comment with an :on_nl" do
          subject.remove_trailing_comment(file_text).should == [
            [[1, 0], :on_kw, "def"],
              [[1, 3], :on_sp, " "],
              [[1, 4], :on_ident, "thing"],
              [[1, 9], :on_sp, " "],
              [[1, 10], :on_ident, "one"],
              [[1, 13], :on_nl, "\n"]
          ]
        end
        
        it "returns a LexedLine" do
          subject.remove_trailing_comment(file_text).should be_a Tailor::LexedLine
        end
      end
    end
  end
end
