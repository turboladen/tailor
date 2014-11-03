require 'spec_helper'
require 'tailor/lexed_line'

describe Tailor::LexedLine do
  before do
    allow(Tailor::Logger).to receive(:log)
  end

  subject { Tailor::LexedLine.new(lexed_output, 1) }

  describe '#initialize' do
    let(:lexed_output) do
      [
        [[1, 0], :on_ident, 'require'],
        [[1, 7], :on_sp, ' '],
        [[1, 8], :on_tstring_beg, "'"],
        [[1, 9], :on_tstring_content, 'log_switch'],
        [[1, 19], :on_tstring_end, "'"],
        [[1, 20], :on_nl, "\n"],
        [[2, 0], :on_ident, 'require_relative'],
        [[2, 16], :on_sp, ' '],
        [[2, 17], :on_tstring_beg, "'"],
        [[2, 18], :on_tstring_content, 'tailor/runtime_error'],
        [[2, 38], :on_tstring_end, "'"],
        [[2, 39], :on_nl, "\n"]
      ]
    end

    it 'returns all lexed output from line 1 when self.lineno is 1' do
      line = Tailor::LexedLine.new(lexed_output, 1)

      expect(line).to eq [
        [[1, 0], :on_ident, 'require'],
        [[1, 7], :on_sp, ' '],
        [[1, 8], :on_tstring_beg, "'"],
        [[1, 9], :on_tstring_content, 'log_switch'],
        [[1, 19], :on_tstring_end, "'"],
        [[1, 20], :on_nl, "\n"]
      ]
    end
  end

  describe '#only_spaces?' do
    context '0 length line, no \n ending' do
      let(:lexed_output) { [[[1, 0], :on_sp, '  ']] }

      it 'is true' do
        expect(subject.only_spaces?).to eq true
      end
    end

    context '0 length line, with \n ending' do
      let(:lexed_output) { [[[1, 0], :on_nl, "\n"]] }

      it 'is true' do
        expect(subject.only_spaces?).to eq true
      end
    end

    context 'comment line, starting at column 0' do
      let(:lexed_output) { [[[1, 0], :on_comment, '# comment']] }

      it 'is false' do
        expect(subject.only_spaces?).to eq false
      end
    end

    context 'comment line, starting at column 2' do
      let(:lexed_output) do
        [
          [[1, 0], :on_sp, '  '],
          [[1, 2], :on_comment, '# comment']
        ]
      end

      it 'is false' do
        expect(subject.only_spaces?).to eq false
      end
    end

    context 'code line, starting at column 2' do
      let(:lexed_output) do
        [
          [[1, 0], :on_ident, 'puts'],
          [[1, 4], :on_sp, ' '],
          [[1, 5], :on_tstring_beg, "'"],
          [[1, 6], :on_tstring_content, 'thing'],
          [[1, 11], :on_tstring_end, "'"],
          [[1, 12], :on_nl, "\n"]
        ]
      end

      it 'is false' do
        expect(subject.only_spaces?).to eq false
      end
    end
  end

  describe '#ends_with_op?' do
    context 'line ends with a +, then \\n' do
      let(:lexed_output) do
        [
          [[1, 0], :on_ident, 'thing'],
          [[1, 5], :on_sp, ' '],
          [[1, 6], :on_op, '='],
          [[1, 7], :on_sp, ' '],
          [[1, 8], :on_int, '1'],
          [[1, 9], :on_sp, ' '],
          [[1, 10], :on_op, '+'],
          [[1, 11], :on_ignored_nl, "\n"],
          [[1, 11], :on_ignored_nl, "\n"]
        ]
      end

      it 'returns true' do
        expect(subject.ends_with_op?).to eq true
      end
    end

    context 'line ends with not an operator, then \\n' do
      let(:lexed_output) do
        [
          [[1, 0], :on_ident, 'thing'],
          [[1, 5], :on_sp, ' '],
          [[1, 6], :on_op, '='],
          [[1, 7], :on_sp, ' '],
          [[1, 8], :on_int, '1'],
          [[1, 11], :on_nl, "\n"]
        ]
      end

      it 'returns false' do
        expect(subject.ends_with_op?).to eq false
      end
    end
  end

  describe '#ends_with_modifier_kw?' do
    context 'ends_with_kw? is false' do
      let(:lexed_output) do
        [
          [[1, 0], :on_ident, 'thing'],
          [[1, 5], :on_sp, ' '],
          [[1, 6], :on_op, '='],
          [[1, 7], :on_sp, ' '],
          [[1, 8], :on_int, '1'],
          [[1, 9], :on_ignored_nl, "\n"]
        ]
      end

      before { allow(subject).to receive(:ends_with_kw?).and_return true }

      it 'returns false' do
        expect(subject.ends_with_modifier_kw?).to eq false
      end
    end

    context '#ends_with_kw? is true' do
      let(:lexed_output) do
        [
          [[1, 0], :on_ident, 'thing'],
          [[1, 5], :on_sp, ' '],
          [[1, 6], :on_op, '='],
          [[1, 7], :on_sp, ' '],
          [[1, 8], :on_int, '1'],
          [[1, 9], :on_sp, ' '],
          [[1, 10], :on_kw, 'if'],
          [[1, 12], :on_ignored_nl, "\n"]
        ]
      end

      let(:token) { double 'Token' }

      context 'the keyword is a modifier' do
        before do
          allow(token).to receive(:modifier_keyword?).and_return true
          allow(Tailor::Lexer::Token).to receive(:new).and_return token
          allow(subject).to receive(:ends_with_kw?).and_return true
        end

        it 'returns true' do
          expect(subject.ends_with_modifier_kw?).to eq true
        end
      end

      context 'the keyword is not a modifier' do
        before do
          allow(token).to receive(:modifier_keyword?).and_return false
          allow(Tailor::Lexer::Token).to receive(:new).and_return token
          allow(subject).to receive(:ends_with_kw?).and_return true
        end

        it 'returns false' do
          expect(subject.ends_with_modifier_kw?).to eq false
        end
      end
    end
  end

  describe '#does_line_end_with' do
    let(:lexed_output) do
      [
        [[1, 0], :on_kw, 'def'],
        [[1, 3], :on_sp, ' '],
        [[1, 4], :on_ident, 'thing'],
        [[1, 9], :on_sp, ' '],
        [[1, 10], :on_nl, "\n"]
      ]
    end

    context 'line ends with the event' do
      it 'returns true' do
        expect(subject.does_line_end_with(:on_sp)).to eq true
      end
    end

    context 'line does not even with event' do
      it 'returns false' do
        expect(subject.does_line_end_with(:on_kw)).to eq false
      end
    end
  end

  describe '#last_non_line_feed_event' do
    context 'line ends with a space' do
      let(:lexed_output) do
        [
          [[1, 0], :on_kw, 'def'],
          [[1, 3], :on_sp, ' '],
          [[1, 4], :on_ident, 'thing'],
          [[1, 9], :on_sp, ' '],
          [[1, 10], :on_nl, "\n"]
        ]
      end

      it 'returns the space' do
        expect(subject.last_non_line_feed_event).to eq [[1, 9], :on_sp, ' ']
      end
    end

    context 'line ends with a backslash' do
      let(:lexed_output) do
        [
          [[1, 0], :on_kw, 'def'],
          [[1, 3], :on_sp, ' '],
          [[1, 4], :on_ident, 'thing'],
          [[1, 9], :on_sp, "\\\n"]
        ]
      end

      it 'returns the event before it' do
        expect(subject.last_non_line_feed_event).
          to eq [[1, 4], :on_ident, 'thing']
      end
    end
  end

  describe '#loop_with_do?' do
    context "line is 'while true do\\n'" do
      let(:lexed_output) do
        [
          [[1, 0], :on_kw, 'while'],
          [[1, 5], :on_sp, ' '],
          [[1, 6], :on_kw, 'true'],
          [[1, 10], :on_sp, ' '],
          [[1, 11], :on_kw, 'do'],
          [[1, 13], :on_ignored_nl, "\n"]
        ]
      end

      it 'returns true' do
        expect(subject.loop_with_do?).to eq true
      end
    end

    context "line is 'while true\\n'" do
      let(:lexed_output) do
        [
          [[1, 0], :on_kw, 'while'],
          [[1, 5], :on_sp, ' '],
          [[1, 6], :on_kw, 'true'],
          [[1, 10], :on_sp, ' '],
          [[1, 11], :on_ignored_nl, "\n"]
        ]
      end

      it 'returns false' do
        expect(subject.loop_with_do?).to eq false
      end
    end

    context "line is 'until true do\\n'" do
      let(:lexed_output) do
        [
          [[1, 0], :on_kw, 'until'],
          [[1, 5], :on_sp, ' '],
          [[1, 6], :on_kw, 'true'],
          [[1, 10], :on_sp, ' '],
          [[1, 11], :on_kw, 'do'],
          [[1, 13], :on_ignored_nl, "\n"]
        ]
      end

      it 'returns true' do
        expect(subject.loop_with_do?).to eq true
      end
    end

    context "line is 'until true\\n'" do
      let(:lexed_output) do
        [
          [[1, 0], :on_kw, 'until'],
          [[1, 5], :on_sp, ' '],
          [[1, 6], :on_kw, 'true'],
          [[1, 10], :on_sp, ' '],
          [[1, 11], :on_ignored_nl, "\n"]
        ]
      end

      it 'returns false' do
        expect(subject.loop_with_do?).to eq false
      end
    end

    context "line is 'for i in 1..5 do\\n'" do
      let(:lexed_output) do
        [
          [[1, 0], :on_kw, 'for'],
          [[1, 3], :on_sp, ' '],
          [[1, 4], :on_ident, 'i'],
          [[1, 5], :on_sp, ' '],
          [[1, 6], :on_kw, 'in'],
          [[1, 8], :on_sp, ' '],
          [[1, 9], :on_int, '1'],
          [[1, 10], :on_op, '..'],
          [[1, 12], :on_int, '5'],
          [[1, 13], :on_sp, ' '],
          [[1, 14], :on_kw, 'do'],
          [[1, 16], :on_ignored_nl, "\n"]
        ]
      end

      it 'returns true' do
        expect(subject.loop_with_do?).to eq true
      end
    end

    context "line is 'for i in 1..5\\n'" do
      let(:lexed_output) do
        [
          [[1, 0], :on_kw, 'for'],
          [[1, 3], :on_sp, ' '],
          [[1, 4], :on_ident, 'i'],
          [[1, 5], :on_sp, ' '],
          [[1, 6], :on_kw, 'in'],
          [[1, 8], :on_sp, ' '],
          [[1, 9], :on_int, '1'],
          [[1, 10], :on_op, '..'],
          [[1, 12], :on_int, '5'],
          [[1, 13], :on_sp, ' '],
          [[1, 14], :on_ignored_nl, "\n"]
        ]
      end

      it 'returns false' do
        expect(subject.loop_with_do?).to eq false
      end
    end
  end

  describe '#first_non_space_element' do
    context 'lexed line contains only spaces' do
      let(:lexed_output) { [[[1, 0], :on_sp, '     ']] }

      it 'returns nil' do
        expect(subject.first_non_space_element).to be_nil
      end
    end

    context 'lexed line contains only \n' do
      let(:lexed_output) { [[[1, 0], :on_ignored_nl, "\n"]] }

      it 'returns nil' do
        expect(subject.first_non_space_element).to be_nil
      end
    end

    context "lexed line contains '  }\\n'" do
      let(:lexed_output) do
        [
          [[1, 0], :on_sp, '  '],
          [[1, 2], :on_rbrace, '}'],
          [[1, 3], :on_nl, "\n"]
        ]
      end

      it 'returns the token array' do
        expect(subject.first_non_space_element).to eq [[1, 2], :on_rbrace, '}']
      end
    end
  end

  describe '#event_at' do
    let(:lexed_output) { [[[1, 0], :on_sp, '     ']] }

    context 'self contains an event at the given column' do
      it 'returns that event' do
        expect(subject.event_at(0)).to eq lexed_output.first
      end
    end

    context 'self does not contain an event at the given column' do
      it 'returns nil' do
        expect(subject.event_at(1234)).to be_nil
      end
    end
  end

  describe '#event_index' do
    let(:lexed_output) { [[[1, 0], :on_sp, '     ']] }

    context '#event_at returns nil' do
      before { allow(subject).to receive(:event_at).and_return nil }
      specify { expect(subject.event_index(1234)).to be_nil }
    end

    context '#event_at returns a valid column' do
      it 'returns the event' do
        expect(subject.event_index(0)).to be_zero
      end
    end
  end

  describe '#to_s' do
    let(:lexed_output) do
      [
        [[1, 0], :on_kw, 'def'],
        [[1, 3], :on_sp, ' '],
        [[1, 4], :on_ident, 'thing'],
        [[1, 9], :on_sp, ' '],
        [[1, 10], :on_nl, "\n"]
      ]
    end

    it "returns the String made up of self's tokens" do
      expect(subject.to_s).to eq "def thing \n"
    end
  end

  describe '#remove_comment_at' do
    context 'stuff before comment is an incomplete statement' do
      context 'spaces before comment' do
        let(:lexed_output) do
          [
            [[1, 0], :on_kw, 'def'],
            [[1, 3], :on_sp, ' '],
            [[1, 4], :on_ident, 'thing'],
            [[1, 9], :on_sp, ' '],
            [[1, 10], :on_ident, 'one'],
            [[1, 13], :on_comma, ','],
            [[1, 14], :on_sp, '  '],
            [[1, 16], :on_comment, "# comment\n"]
          ]
        end

        let(:file_text) do
          "def thing one,  # comment\n  two\nend\n"
        end

        it 'replaces the comment with an :on_ignored_nl' do
          expect(subject.remove_trailing_comment(file_text)).to eq [
            [[1, 0], :on_kw, 'def'],
            [[1, 3], :on_sp, ' '],
            [[1, 4], :on_ident, 'thing'],
            [[1, 9], :on_sp, ' '],
            [[1, 10], :on_ident, 'one'],
            [[1, 13], :on_comma, ','],
            [[1, 14], :on_ignored_nl, "\n"]
          ]
        end
      end

      context 'no spaces before comment' do
        let(:lexed_output) do
          [
            [[1, 0], :on_kw, 'def'],
            [[1, 3], :on_sp, ' '],
            [[1, 4], :on_ident, 'thing'],
            [[1, 9], :on_sp, ' '],
            [[1, 10], :on_ident, 'one'],
            [[1, 13], :on_comma, ','],
            [[1, 14], :on_comment, "# comment\n"]
          ]
        end

        let(:file_text) do
          "def thing one,# comment\n  two\nend\n"
        end

        it 'replaces the comment with an :on_ignored_nl' do
          expect(subject.remove_trailing_comment(file_text)).to eq [
            [[1, 0], :on_kw, 'def'],
            [[1, 3], :on_sp, ' '],
            [[1, 4], :on_ident, 'thing'],
            [[1, 9], :on_sp, ' '],
            [[1, 10], :on_ident, 'one'],
            [[1, 13], :on_comma, ','],
            [[1, 14], :on_ignored_nl, "\n"]
          ]
        end
      end
    end

    context 'stuff before comment is a complete statement' do
      context 'spaces before comment' do
        let(:lexed_output) do
          [
            [[1, 0], :on_kw, 'def'],
            [[1, 3], :on_sp, ' '],
            [[1, 4], :on_ident, 'thing'],
            [[1, 9], :on_sp, ' '],
            [[1, 10], :on_ident, 'one'],
            [[1, 13], :on_sp, '  '],
            [[1, 15], :on_comment, "# comment\n"]
          ]
        end

        let(:file_text) do
          "def thing one  # comment\n\nend\n"
        end

        it 'replaces the comment with an :on_nl' do
          expect(subject.remove_trailing_comment(file_text)).to eq [
            [[1, 0], :on_kw, 'def'],
            [[1, 3], :on_sp, ' '],
            [[1, 4], :on_ident, 'thing'],
            [[1, 9], :on_sp, ' '],
            [[1, 10], :on_ident, 'one'],
            [[1, 13], :on_nl, "\n"]
          ]
        end
      end

      context 'no spaces before comment' do
        let(:lexed_output) do
          [
            [[1, 0], :on_kw, 'def'],
            [[1, 3], :on_sp, ' '],
            [[1, 4], :on_ident, 'thing'],
            [[1, 9], :on_sp, ' '],
            [[1, 10], :on_ident, 'one'],
            [[1, 13], :on_comment, "# comment\n"]
          ]
        end

        let(:file_text) do
          "def thing one# comment\n  \nend\n"
        end

        it 'replaces the comment with an :on_nl' do
          expect(subject.remove_trailing_comment(file_text)).to eq [
            [[1, 0], :on_kw, 'def'],
            [[1, 3], :on_sp, ' '],
            [[1, 4], :on_ident, 'thing'],
            [[1, 9], :on_sp, ' '],
            [[1, 10], :on_ident, 'one'],
            [[1, 13], :on_nl, "\n"]
          ]
        end

        it 'returns a LexedLine' do
          expect(subject.remove_trailing_comment(file_text)).
            to be_a Tailor::LexedLine
        end
      end
    end
  end

  describe '#end_of_multi-line_string?' do
    context 'lexed output is from the end of a multi-line % statement' do
      let(:lexed_output) do
        [[[1, 11], :on_tstring_end, '}'], [[1, 12], :on_nl, "\n"]]
      end

      it 'returns true' do
        expect(subject.end_of_multi_line_string?).to eq true
      end
    end

    context 'lexed output is not from the end of a multi-line % statement' do
      let(:lexed_output) do
        [[[1, 11], :on_comma, ','], [[1, 12], :on_nl, "\n"]]
      end

      it 'returns false' do
        expect(subject.end_of_multi_line_string?).to eq false
      end
    end

    context 'lexed output contains start AND end of a multi-line % statement' do
      let(:lexed_output) do
        [
          [[1, 0], :on_tstring_beg, '%Q{'],
          [[1, 3], :on_tstring_content, 'this is a t string! suckaaaaaa!'],
          [[1, 32], :on_tstring_end, '}']
        ]
      end

      it 'returns false' do
        expect(subject.end_of_multi_line_string?).to eq false
      end
    end
  end

  describe '#is_line_only_a' do
    let(:lexed_output) do
      [[[1, 11], :on_comma, ','], [[1, 12], :on_nl, "\n"]]
    end

    context 'last event is not the event passed in' do
      let(:last_event) do
        [[[1, 11], :on_comma, ',']]
      end

      before do
        allow(subject).to receive(:last_non_line_feed_event).
          and_return last_event
      end

      specify { expect(subject.is_line_only_a(:on_period)).to eq false }
    end

    context 'last event is the last event passed in' do
      context 'there is only space before the last event' do
        let(:lexed_output) do
          [
            [[1, 0], :on_sp, '          '],
            [[1, 11], :on_comma, ','],
            [[1, 12], :on_nl, "\n"]]
        end

        specify { expect(subject.is_line_only_a(:on_comma)).to eq true }
      end

      context 'there is non-spaces before the last event' do
        let(:lexed_output) do
          [
            [[1, 0], :on_sp, '        '],
            [[1, 8], :on_ident, 'one'],
            [[1, 11], :on_comma, ','],
            [[1, 12], :on_nl, "\n"]]
        end

        specify { expect(subject.is_line_only_a(:on_comma)).to eq false }
      end
    end
  end

  describe '#keyword_is_symbol?' do
    context 'last event in line is not a keyword' do
      let(:lexed_output) do
        [
          [[1, 0], :on_sp, '        '],
          [[1, 8], :on_ident, 'one'],
          [[1, 11], :on_comma, ','],
          [[1, 12], :on_nl, "\n"]]
      end

      it 'returns false' do
        expect(subject.keyword_is_symbol?).to eq false
      end
    end

    context 'last event in line is a keyword' do
      context 'previous event is nil' do
        let(:lexed_output) do
          [
            [[1, 0], :on_kw, 'class']
          ]
        end

        it 'returns false' do
          expect(subject.keyword_is_symbol?).to eq false
        end
      end

      context 'previous event is not :on_symbeg' do
        let(:lexed_output) do
          [
            [[1, 0], :on_sp, '  '],
            [[1, 2], :on_kw, 'class']
          ]
        end

        it 'returns false' do
          expect(subject.keyword_is_symbol?).to eq false
        end
      end

      context 'previous event is :on_symbeg' do
        let(:lexed_output) do
          [
            [[1, 0], :on_const, 'INDENT_OK'],
            [[1, 9], :on_lbracket, '['],
            [[1, 10], :on_symbeg, ':'],
            [[1, 11], :on_kw, 'class']]
        end

        it 'returns true' do
          expect(subject.keyword_is_symbol?).to eq true
        end
      end
    end
  end
end
