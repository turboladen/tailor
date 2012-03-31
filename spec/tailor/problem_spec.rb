require_relative '../spec_helper'
require 'tailor/problem'

describe Tailor::Problem do
  before do
    Tailor::Problem.any_instance.stub(:log)
  end
  
  let(:lineno) { 10 }
  let(:column) { 11 }

  describe "#set_values" do
    before do
      Tailor::Problem.any_instance.stub(:message)
    end

    it "sets self[:type] to the type param" do
      Tailor::Problem.new(:test, lineno, column).should include(type: :test)
    end

    it "sets self[:line] to the lineno param" do
      Tailor::Problem.new(:test, lineno, column).should include(line: lineno)
    end

    it "sets self[:column] to 'column' from the binding" do
      Tailor::Problem.new(:test, lineno, column).should include(column: column)
    end

    it "sets self[:message] to what's returned from #message for @type" do
      Tailor::Problem.any_instance.should_receive(:message).with(:test).
        and_return("test message")

      problem = Tailor::Problem.new(:test, lineno, column)
      problem.should include(message: "test message")
    end
  end

  describe "#message" do
    before do
      Tailor::Problem.any_instance.stub(:set_values)
    end

    context "type is :indentation" do
      it "builds a successful message" do
        options = { actual_indentation: 10, should_be_at: 97 }
        problem = Tailor::Problem.new(:test, lineno, column, options)
        problem.message(:indentation).should match /10.*97/
      end
    end

    context "type is :trailing_newlines" do
      it "builds a successful message" do
        options = { actual_trailing_newlines: 123, should_have: 777 }
        problem = Tailor::Problem.new(:test, lineno, column, options)
        problem.message(:trailing_newlines).should match /123.*777/
      end
    end

    context "type is :hard_tab" do
      it "builds a successful message" do
        problem = Tailor::Problem.new(:test, lineno, column)
        problem.message(:hard_tab).should match /Hard tab found./
      end
    end

    context "type is :line_length" do
      it "builds a successful message" do
        options = { actual_length: 88, should_be_at: 77 }
        problem = Tailor::Problem.new(:test, lineno, column, options)
        problem.message(:line_length).should match /88.*77/
      end
    end
  end
end
