require_relative '../../spec_helper'
require 'tailor/rulers/indentation_spaces_ruler'
require 'ripper'

describe Tailor::Rulers::IndentationSpacesRuler do
  let!(:spaces) { 5 }

  subject do
    Tailor::Rulers::IndentationSpacesRuler.new(spaces, level: :error)
  end

  describe "#comment_update" do
    pending
    context "token does not contain a trailing newline" do

    end

    context "token contains a trailing newline" do
      context "lexed_line is spaces then a comment" do

      end

      context "lexed_line is no spaces and a comment" do

      end

      context "lexed_line ends with an operator" do

      end

      context "lexed_line ends with a comma" do

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
    let(:lexed_line) { double "LexedLine" }
    let(:manager) { double "IndentationManager" }

    it "calls #stop on the indentation_manager object" do
      manager.should_receive(:update_actual_indentation).with lexed_line
      manager.should_receive(:stop)
      subject.instance_variable_set(:@manager, manager)
      subject.tstring_beg_update(lexed_line, 1)
    end

    it "adds the lineno to @tstring_nesting" do
      manager.stub(:update_actual_indentation)
      manager.stub(:stop)
      subject.instance_variable_set(:@manager, manager)
      subject.tstring_beg_update(lexed_line, 1)
      subject.instance_variable_get(:@tstring_nesting).should == [1]
    end
  end

  describe "#tstring_end_update" do
    context "@tstring_nesting is not empty" do
      let(:lexed_line) { double "LexedLine" }
      let(:manager) { double "IndentationManager" }

      it "calls #start" do
        manager.should_receive(:start)
        subject.instance_variable_set(:@manager, manager)
        subject.tstring_end_update(2)
      end

      it "removes the lineno to @tstring_nesting then calls @manager.start" do
        manager.should_receive(:actual_indentation)
        manager.should_receive(:start)
        subject.instance_variable_set(:@manager, manager)
        subject.instance_variable_set(:@tstring_nesting, [1])
        subject.should_receive(:measure)
        subject.tstring_end_update(2)
        subject.instance_variable_get(:@tstring_nesting).should be_empty
      end
    end
  end
end
