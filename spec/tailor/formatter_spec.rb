require_relative '../spec_helper'
require 'tailor/formatter'

describe Tailor::Formatter do
  describe "#problems_at_level" do
    let(:problems) do
      {
        "some_file.rb" => [
          {
            :type => "allow_invalid_ruby",
            :line => 0,
            :column => 0,
            :message => "File contains invalid Ruby; run `ruby -c [your_file.rb]` for more details.",
            :level => :warn
          }
        ]
      }
    end

    context "problems are empty" do
      it "returns an empty Array" do
        subject.problems_at_level({}, :error).should == []
      end
    end

    context "the level asked for exists in the problems" do
      it "returns the problem" do
        subject.problems_at_level(problems, :warn).should == [
          {
            :type => "allow_invalid_ruby",
            :line => 0,
            :column => 0,
            :message => "File contains invalid Ruby; run `ruby -c [your_file.rb]` for more details.",
            :level => :warn
          }
        ]
      end
    end

    context "the level asked for does not exist in the problems" do
      it "returns an empty Array" do
        subject.problems_at_level(problems, :error).should == []
      end
    end
  end
end
