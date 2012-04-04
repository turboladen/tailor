require_relative '../../spec_helper'
require 'tailor/lexer/token'

describe Tailor::Lexer::Token do
  before do
    Tailor::Logger.stub(:log)
  end

  describe "#modifier_keyword?" do
    subject do
      options = { full_line_of_text: full_line_of_text }
      Tailor::Lexer::Token.new("if", options)
    end

    context "the current line has a keyword that is also a modifier" do
      context "the keyword is acting as a modifier" do
        let!(:full_line_of_text) { %q{puts "hi" if true == true} }

        it "returns true" do
          subject.modifier_keyword?.should be_true
        end
      end

      context "they keyword is NOT acting as a modifier" do
        let!(:full_line_of_text) { %q{if true == true; puts "hi"; end} }

        it "returns false" do
          subject.modifier_keyword?.should be_false
        end
      end
    end

    context "the current line doesn't have a keyword" do
      let!(:full_line_of_text) { %q{puts true} }

      subject do
        options = { full_line_of_text: full_line_of_text }
        Tailor::Lexer::Token.new("puts", options)
      end

      it "returns false" do
        subject.modifier_keyword?.should be_false
      end
    end
  end
end
