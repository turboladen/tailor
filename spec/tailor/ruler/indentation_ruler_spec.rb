require_relative '../../spec_helper'
require 'tailor/ruler/indentation_ruler'

describe Tailor::Ruler::IndentationRuler do
  let!(:spaces) { 5 }

  subject do
    Tailor::Ruler::IndentationRuler.new({ spaces: spaces })
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

  describe "#increase_next_line" do
    it "increases @proper_indentation[:next_line] by @config[:spaces]" do
      expect { subject.increase_next_line }.to change{subject.next_should_be_at}.
        by(spaces)
    end
  end

  describe "#decrease_next_line" do
    let!(:spaces) { 27 }

    it "decrements @proper_indentation[:next_line] by @config[:spaces]" do
      expect { subject.decrease_next_line }.to change{subject.next_should_be_at}.
        by(-spaces)
    end
  end

  describe "#transition_lines" do
    it "sets @proper_indentation[:this_line] to @proper_indentation[:next_line]" do
      subject.instance_variable_set(:@proper_indentation, { next_line: 33 })

      expect { subject.transition_lines }.to change{subject.should_be_at}.
        from(subject.should_be_at).to(subject.next_should_be_at)
    end
  end
end
