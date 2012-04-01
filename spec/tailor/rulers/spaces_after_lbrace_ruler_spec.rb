require_relative '../../spec_helper'
require 'tailor/rulers/spaces_after_lbrace_ruler'

describe Tailor::Rulers::SpacesAfterLbraceRuler do
  subject { Tailor::Rulers::SpacesAfterLbraceRuler.new('')}
  
  describe "#comment_update" do
    context "token has a trailing newline" do
      it "calls #ignored_nl_update" do
        subject.should_receive(:ignored_nl_update)
        subject.comment_update("\n", '', '', 1, 1)
      end
    end
    
    context "token does not have a trailing newline" do
      it "does not call #ignored_nl_update" do
        subject.should_not_receive(:ignored_nl_update)
        subject.comment_update("# comment", '', '', 1, 1)
      end
    end
  end
  
  describe "#ignored_nl_update" do
    it "calls #check_spaces_after_lbrace" do
      subject.should_receive(:check_spaces_after_lbrace)
      subject.ignored_nl_update('', 1, 1)
    end
  end
  
  describe "#lbrace_update" do
    it "adds column to @lbrace_columns" do
      subject.lbrace_update('', 1, 1)
      subject.instance_variable_get(:@lbrace_columns).should == [1]
    end
  end
  
  describe "#nl_update" do
    it "calls #ignored_nl_update" do
      subject.should_receive(:ignored_nl_update)
      subject.nl_update('', 1, 1)
    end
  end
  
  describe "#count_spaces" do
    context "lexed_line.event_index returns nil" do
      let(:lexed_line) do
        l = double "LexedLine"
        l.stub(:event_index).and_return nil
        
        l
      end
      
      it "breaks from the loop and returns nil" do
        lexed_line.should_not_receive(:at)
        subject.count_spaces(lexed_line, 1).should be_nil
      end
    end
    
    context "lexed_line.at returns nil" do
      let(:lexed_line) do
        l = double "LexedLine"
        l.stub(:event_index).and_return 1
        l.stub(:at).and_return nil

        l
      end

      it "breaks from the loop and returns nil" do
        subject.count_spaces(lexed_line, 1).should be_nil
      end
    end
    
    context "next_event is a :on_nl" do
      let!(:next_event) do
        [[1,1], :on_nl, "\n"]
      end

      let(:lexed_line) do
        l = double "LexedLine"
        l.stub(:event_index).and_return 1
        l.should_receive(:at).with(2).and_return next_event

        l
      end

      it "breaks from the loop and returns nil" do
        subject.count_spaces(lexed_line, 1).should be_nil
      end
    end

    context "next_event is a :on_ignored_nl" do
      let!(:next_event) do
        [[1,1], :on_ignored_nl, "\n"]
      end

      let(:lexed_line) do
        l = double "LexedLine"
        l.stub(:event_index).and_return 1
        l.should_receive(:at).with(2).and_return next_event

        l
      end

      it "breaks from the loop and returns nil" do
        subject.count_spaces(lexed_line, 1)
      end
    end

    context "next_event is a non-space event" do
      let!(:next_event) do
        [[1,1], :on_kw, "def"]
      end

      let(:lexed_line) do
        l = double "LexedLine"
        l.stub(:event_index).and_return 1
        l.stub(:at).and_return next_event

        l
      end

      it "returns 0" do
        subject.count_spaces(lexed_line, 1).should be_zero
      end
    end

    context "next_event is :on_sp" do
      let!(:next_event) do
        [[1,1], :on_sp, "  "]
      end

      let(:lexed_line) do
        l = double "LexedLine"
        l.stub(:event_index).and_return 1
        l.stub(:at).and_return next_event

        l
      end

      it "returns 2" do
        subject.count_spaces(lexed_line, 1).should == 2
      end
    end
  end
end
