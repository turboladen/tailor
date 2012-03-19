require_relative '../spec_helper'
require 'tailor/reporter'

describe Tailor::Reporter do
  describe "#initialize" do
    context "text formatter" do
      let(:formats) { ['text'] }

      it "creates a new Text object" do
        reporter = Tailor::Reporter.new(formats)
        reporter.formatters.first.should be_a Tailor::Formatter::Text
      end
    end
  end
end
