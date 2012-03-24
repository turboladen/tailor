require_relative '../../spec_helper'
require 'tailor/ruler/indentation_ruler'
require 'ripper'

describe Tailor::IndentationRuler do
  let!(:spaces) { 5 }

  subject do
    Tailor::IndentationRuler.new({ spaces: spaces })
  end

  describe "#initialize" do
    it "sets @proper_indentation to an Hash with :this_line and :next_line keys = 0" do
      proper_indentation = subject.instance_variable_get(:@proper_indentation)
      proper_indentation.should be_a Hash
      proper_indentation[:this_line].should be_zero
      proper_indentation[:next_line].should be_zero
    end
  end

  describe "#should_be_at" do
    it "returns @proper_indentation[:this_line]" do
      subject.instance_variable_set(:@proper_indentation, { this_line: 321 })
      subject.should_be_at.should == 321
    end
  end

  describe "#next_should_be_at" do
    it "returns @proper_indentation[:next_line]" do
      subject.instance_variable_set(:@proper_indentation, { next_line: 123 })
      subject.next_should_be_at.should == 123
    end
  end

  describe "#decrease_this_line" do
    let!(:spaces) { 27 }

    context "#started? is true" do
      before { subject.stub(:started?).and_return true }

      context "@proper_indentation[:this_line] gets decremented < 0" do
        it "sets @proper_indentation[:this_line] to 0" do
          subject.instance_variable_set(:@proper_indentation, {
            this_line: 0, next_line: 0
          })

          subject.decrease_this_line
          proper_indentation = subject.instance_variable_get(:@proper_indentation)
          proper_indentation[:this_line].should == 0
        end
      end

      context "@proper_indentation[:this_line] NOT decremented < 0" do
        it "decrements @proper_indentation[:this_line] by @config[:spaces]" do
          subject.instance_variable_set(:@proper_indentation, {
            this_line: 28, next_line: 28
          })
          subject.decrease_this_line

          proper_indentation = subject.instance_variable_get(:@proper_indentation)
          proper_indentation[:this_line].should == 1
        end
      end
    end

    context "#started? is false" do
      before { subject.stub(:started?).and_return false }

      it "does not decrement @proper_indentation[:this_line]" do
        subject.instance_variable_set(:@proper_indentation, {
          this_line: 28, next_line: 28
        })
        subject.decrease_this_line

        proper_indentation = subject.instance_variable_get(:@proper_indentation)
        proper_indentation[:this_line].should == 28
      end
    end
  end

  describe "#increase_next_line" do
    context "#started? is true" do
      before { subject.stub(:started?).and_return true }

      it "increases @proper_indentation[:next_line] by @config[:spaces]" do
        expect { subject.increase_next_line }.to change{subject.next_should_be_at}.
          by(spaces)
      end
    end

    context "#started? is false" do
      before { subject.stub(:started?).and_return false }

      it "does not increases @proper_indentation[:next_line]" do
        expect { subject.increase_next_line }.to_not change{subject.next_should_be_at}.
          by(spaces)
      end
    end
  end

  describe "#decrease_next_line" do
    let!(:spaces) { 27 }

    context "#started? is true" do
      before { subject.stub(:started?).and_return true }

      it "decrements @proper_indentation[:next_line] by @config[:spaces]" do
        expect { subject.decrease_next_line }.to change{subject.next_should_be_at}.
          by(-spaces)
      end
    end

    context "#started? is false" do
      before { subject.stub(:started?).and_return false }

      it "decrements @proper_indentation[:next_line] by @config[:spaces]" do
        expect { subject.decrease_next_line }.to_not change{subject.next_should_be_at}.
          by(-spaces)
      end
    end
  end

  describe "#set_up_line_transition" do
    pending
  end

  describe "#transition_lines" do
    context "#started? is true" do
      before { subject.stub(:started?).and_return true }

      it "sets @proper_indentation[:this_line] to @proper_indentation[:next_line]" do
      subject.instance_variable_set(:@proper_indentation, { next_line: 33 })

      expect { subject.transition_lines }.to change{subject.should_be_at}.
        from(subject.should_be_at).to(subject.next_should_be_at)
      end
    end

    context "#started? is true" do
      before { subject.stub(:started?).and_return false }

      it "sets @proper_indentation[:this_line] to @proper_indentation[:next_line]" do
        subject.instance_variable_set(:@proper_indentation, { next_line: 33 })

        expect { subject.transition_lines }.to_not change{subject.should_be_at}.
          from(subject.should_be_at).to(subject.next_should_be_at)
      end
    end
  end

  describe "#start" do
    it "sets @started to true" do
      subject.instance_variable_set(:@started, false)
      subject.start
      subject.instance_variable_get(:@started).should be_true
    end
  end

  describe "#stop" do
    it "sets @started to false" do
      subject.instance_variable_set(:@started, true)
      subject.stop
      subject.instance_variable_get(:@started).should be_false
    end
  end

  describe "#started?" do
    context "@started is true" do
      before { subject.instance_variable_set(:@started, true) }
      specify { subject.started?.should be_true }
    end

    context "@started is false" do
      before { subject.instance_variable_set(:@started, false) }
      specify { subject.started?.should be_false }
    end
  end

  describe "#update_actual_indentation" do
    context "when indented 0" do
      let(:file_text) { "puts 'something'" }

      it "sets @actual_indentation to 0" do
        subject.update_actual_indentation(Ripper.lex(file_text))
        subject.instance_variable_get(:@actual_indentation).should be_zero
      end
    end

    context "when indented 1" do
      let(:file_text) { " puts 'something'" }

      it "returns 1" do
        subject.update_actual_indentation(Ripper.lex(file_text))
        subject.instance_variable_get(:@actual_indentation).should == 1
      end
    end

    context "when end of a multi-line string" do
      let(:lexed_output) do
        [[[2, 11], :on_tstring_end, "}"], [[2, 12], :on_nl, "\n"]]
      end

      it "returns @actual_indentation from the first line" do
        subject.instance_variable_set(:@actual_indentation, 123)
        subject.update_actual_indentation(lexed_output)
        subject.instance_variable_get(:@actual_indentation).should == 123
      end
    end
  end

  describe "#end_of_multi-line_string?" do
    context "lexed output is from the end of a multi-line % statement" do
      let(:lexed_output) do
        [[[2, 11], :on_tstring_end, "}"], [[2, 12], :on_nl, "\n"]]
      end

      it "returns true" do
        subject.end_of_multi_line_string?(lexed_output).should be_true
      end
    end

    context "lexed output is not from the end of a multi-line % statement" do
      let(:lexed_output) do
        [[[2, 11], :on_comma, ","], [[2, 12], :on_nl, "\n"]]
      end

      it "returns true" do
        subject.end_of_multi_line_string?(lexed_output).should be_false
      end
    end

    context "lexed output contains start AND end of a multi-line % statement" do
      let(:lexed_output) do
        [
          [[1, 0], :on_tstring_beg, "%Q{"],
          [[1, 3], :on_tstring_content, "this is a t string! suckaaaaaa!"],
          [[1, 32], :on_tstring_end, "}"]
        ]
      end

      it "returns true" do
        subject.end_of_multi_line_string?(lexed_output).should be_false
      end
    end
  end

  describe "#valid_line?" do
    pending
  end

  describe "#comma_update" do
    context "column is the last in the line" do
      it "sets @last_comma_statement_line to lineno" do
        subject.comma_update(",", 100, 1)
        subject.instance_variable_get(:@last_comma_statement_line).
          should == 100
      end
    end

    context "column is NOT the last in the line" do
      it "does not set @last_comma_statement_line to lineno" do
        subject.comma_update("text,", 100, 1)
        subject.instance_variable_get(:@last_comma_statement_line).
          should be_nil
      end
    end
  end

  describe "#embexpr_beg_update" do
    it "sets @embexpr_beg to true" do
      subject.instance_variable_set(:@embexpr_beg, false)
      subject.embexpr_beg_update
      subject.instance_variable_get(:@embexpr_beg).should be_true
    end
  end


  describe "#embexpr_end_update" do
    it "sets @embexpr_beg to false" do
      subject.instance_variable_set(:@embexpr_beg, true)
      subject.embexpr_end_update
      subject.instance_variable_get(:@embexpr_beg).should be_false
    end
  end

  describe "#ignored_nl_update" do
    pending
  end

  describe "#kw_update" do
    pending
  end

  describe "#lbrace_update" do
    pending
  end

  describe "#lbracket_update" do
    pending
  end

  describe "#lparen_update" do
    pending
  end

  describe "#nl_update" do
    pending
  end

  describe "#period_update" do
    pending
  end

  describe "#rbrace_update" do
    pending
  end

  describe "#rbracket_update" do
    pending
  end

  describe "#rparen_update" do
    pending
  end

  describe "#tstring_beg_update" do
    pending
  end

  describe "#tstring_end_update" do
    pending
  end

  describe "#single_line_indent_statement?" do
    pending
  end

  describe "#multi_line_braces?" do
    pending
  end

  describe "#multi_line_brackets?" do
    pending
  end

  describe "#multi_line_parens?" do
    pending
  end

  describe "#in_tstring?" do
    pending
  end

  describe "#r_event_without_content?" do
    pending
  end
end
