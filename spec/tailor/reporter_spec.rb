require_relative '../spec_helper'
require 'tailor/reporter'

describe Tailor::Reporter do
  describe "#initialize" do
    context "text formatter" do
      let(:formats) { ['text'] }

      it "creates a new Formatter object of the type passed in" do
        reporter = Tailor::Reporter.new(formats)
        reporter.formatters.first.should be_a Tailor::Formatters::Text
      end
    end
  end

  describe "#file_report" do
    let(:file_problems) { double "file problems" }
    let(:formatter) { double "Tailor::Formatters::SomeFormatter" }

    subject do
      t = Tailor::Reporter.new
      t.instance_variable_set(:@formatters, [formatter])

      t
    end 

    it "calls #file_report on each @formatters" do
      label = :some_label
      formatter.should_receive(:file_report).with(file_problems, label)

      subject.file_report(file_problems, label)
    end
  end

  describe "#summary_report" do
    let(:all_problems) { double "all problems" }
    let(:formatter) { double "Tailor::Formatters::SomeFormatter" }

    subject do
      t = Tailor::Reporter.new
      t.instance_variable_set(:@formatters, [formatter])

      t
    end

    it "calls #file_report on each @formatters" do
      label = :some_label
      formatter.should_receive(:summary_report).with(all_problems)

      subject.summary_report(all_problems)
    end
  end
end
