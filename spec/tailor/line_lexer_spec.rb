require_relative '../spec_helper'
require 'tailor/line_lexer'

describe Tailor::LineLexer do
  let(:file_text) do
    ""
  end

  before do
    File.stub_chain(:open, :read).and_return file_text
    Tailor.stub :log
    Tailor.stub_chain(:config, :[]).and_return({ spaces: 2,
      allow_hard_tabs: false })
  end

  after do
    Tailor.unstub :log
    File.unstub :open
  end

  subject { Tailor::LineLexer.new(file_text) }

  describe "#initialize" do
    it "opens and reads the file by the name passed in" do
      file_name = "test"
      File.should_receive(:open).with("test", 'r')
      Tailor::LineLexer.new(file_name)
    end

    it "sets @proper_indentation to an Hash with :this_line and :next_line keys = 0" do
      proper_indentation = subject.instance_variable_get(:@proper_indentation)
      proper_indentation.should be_a Hash
      proper_indentation[:this_line].should be_zero
      proper_indentation[:next_line].should be_zero
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

  describe "#modifier_keyword?" do
    context "the current line has a keyword that is also a modifier" do
      context "the keyword is acting as a modifier" do
        let(:file_text) do
          <<-FILE
puts "hi" if true == true
          FILE
        end

        before do
          File.stub_chain(:open, :read).and_return file_text
        end

        it "returns true" do
          subject.stub(:lineno).and_return 1
          subject.instance_variable_set(:@file_text, file_text)
          subject.modifier_keyword?("if").should be_true
        end
      end

      context "they keyword is NOT acting as a modifier" do
        let(:file_text) do
          <<-FILE
if true == true; puts "hi"; end
          FILE
        end

        before do
          File.stub_chain(:open, :read).and_return file_text
        end

        it "returns false" do
          subject.stub(:lineno).and_return 1
          subject.instance_variable_set(:@file_text, file_text)
          subject.modifier_keyword?("if").should be_false
        end
      end
    end
  end
end
