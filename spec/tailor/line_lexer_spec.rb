require_relative '../spec_helper'

describe Tailor::LineLexer do
  describe "#initialize" do
    subject { Tailor::LineLexer.new("") }

    it "sets @indentation_tracker to an empty Array" do
      subject.instance_variable_get(:@indentation_tracker).should be_an Array
      subject.instance_variable_get(:@indentation_tracker).should be_empty
    end

    it "sets @proper_indentation a Hash with :this_line and :next_line" do
      subject.instance_variable_get(:@proper_indentation).should be_a Hash
      subject.instance_variable_get(:@proper_indentation).keys.
        should == [
        :this_line,
        :next_line]
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

    subject { Tailor::LineLexer.new("") }

    it "returns all lexed output from line 1 when self.lineno is 1" do
      subject.stub(:lineno).and_return 1
      subject.current_lex(lexed_output).should ==  [[[1, 0], :on_ident, "require"],
        [[1, 7], :on_sp, " "],
        [[1, 8], :on_tstring_beg, "'"],
        [[1, 9], :on_tstring_content, "log_switch"],
        [[1, 19], :on_tstring_end, "'"],
        [[1, 20], :on_nl, "\n"]
      ]
    end
  end

  describe "#on_nl" do

  end
end
