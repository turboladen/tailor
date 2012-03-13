require_relative '../../spec_helper'
require 'tailor/ruler/vertical_whitespace_helpers'

class Thing
  include Tailor::Ruler::VerticalWhitespaceHelpers
  def initialize
    @config = { vertical_whitespace: { trailing_newlines: 10 } }
    @problems = []
  end
end

describe Tailor::Ruler::VerticalWhitespaceHelpers do
  subject do
    t = Thing.new
    t.stub(:log)

    t
  end

  describe "#count_trailing_newlines" do
    context "text contains 0 trailing \\n" do
      let(:text) { "text" }
      specify { subject.count_trailing_newlines(text).should be_zero }
    end

    context "text contains 1 trailing \\n" do
      let(:text) { "text\n" }
      specify { subject.count_trailing_newlines(text).should == 1 }
    end
  end

  describe "#ensure_trailing_newline" do
    context "text contains a trailing newline already" do
      let!(:text) { "text\n" }

      it "doesn't alter the text" do
        subject.ensure_trailing_newline(text).should == text
      end
    end

    context "text does not contain a trailing newline" do
      let!(:text) { "text" }

      it "adds a newline at the end" do
        subject.ensure_trailing_newline(text).should == text + "\n"
      end

      context "@config[:trailing_newlines] > 0" do
        it "logs a problem" do
          subject.instance_variable_set(:@problems, [])
          subject.ensure_trailing_newline(text)

          problems = subject.instance_variable_get(:@problems)
          problems.size.should == 1
          problems.first[:type].should == :trailing_newlines
        end
      end

      context "@config[:trailing_newlines] == 0" do
        before do
          subject.instance_variable_set(:@config,
            { vertical_whitespace: { trailing_newlines: 0 } }
          )
        end

        it "doesn't log a problem" do
          subject.instance_variable_set(:@problems, [])
          subject.ensure_trailing_newline(text)

          problems = subject.instance_variable_get(:@problems)
          problems.size.should be_zero
        end
      end
    end
  end
end
