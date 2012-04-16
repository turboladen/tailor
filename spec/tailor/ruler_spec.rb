require_relative '../spec_helper'
require 'tailor/ruler'

describe Tailor::Ruler do
  before { Tailor::Logger.stub(:log) }

  describe "#add_child_ruler" do
    it "adds new rulers to @child_rulers" do
      ruler = double "Ruler"
      subject.add_child_ruler(ruler)
      subject.instance_variable_get(:@child_rulers).first.should == ruler
    end
  end

  describe "#problems" do
    context "no child_rulers" do
      context "@problems is empty" do
        specify { subject.problems.should be_empty }
      end

      context "@problems.size is 1" do
        before do
          problem = double "Problem"
          problem.should_receive(:[]).with :line
          subject.instance_variable_set(:@problems, [problem])
        end

        specify { subject.problems.size.should == 1 }
      end
    end

    context "child_rulers have problems" do
      before do
        problem = double "Problem"
        problem.should_receive(:[]).with :line
        child_ruler = double "Ruler"
        child_ruler.stub(:problems).and_return([problem])
        subject.instance_variable_set(:@child_rulers, [child_ruler])
      end

      context "@problems is empty" do
        specify { subject.problems.size.should == 1 }
      end

      context "@problems.size is 1" do
        before do
          problem = double "Problem"
          problem.should_receive(:[]).with :line
          subject.instance_variable_set(:@problems, [problem])
        end

        specify { subject.problems.size.should == 2 }
      end
    end
  end
end
