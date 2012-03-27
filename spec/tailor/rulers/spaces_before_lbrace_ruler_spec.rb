require_relative '../../spec_helper'
require 'tailor/rulers/spaces_before_lbrace_ruler'

describe Tailor::Rulers::SpacesBeforeLBraceRuler do
  describe "#count_spaces" do
    context "lbrace is the first char in the line" do
      let(:lexed_line) do
        l = double "LexedLine"
        l.stub(:event_index).and_return 0
        l.stub(:event_at).and_return nil
        
        l
      end
      
      specify { subject.count_spaces(lexed_line, 1).should be_nil }
    end
    
    context "no space before lbrace" do
      let(:lexed_line) do
        l = double "LexedLine"
        l.stub(:event_index).and_return 1
        l.stub(:event_at).and_return [[10, 0], :on_const, "HI"]

        l
      end

      specify { subject.count_spaces(lexed_line, 1).should be_zero }
    end
    
    context "1 space before lbrace" do
      let(:lexed_line) do
        l = double "LexedLine"
        l.stub(:event_index).and_return 1
        l.stub(:event_at).and_return [[10, 0], :on_sp, " "]

        l
      end

      specify { subject.count_spaces(lexed_line, 1).should == 1 }
    end
    
    context "> 1 space before lbrace" do
      let(:lexed_line) do
        l = double "LexedLine"
        l.stub(:event_index).and_return 1
        l.stub(:event_at).and_return [[10, 0], :on_sp, "  "]

        l
      end

      specify { subject.count_spaces(lexed_line, 1).should == 2 }
    end
  end
end
