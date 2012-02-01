require_relative 'spec_helper'
require 'tailor'

describe Tailor do
  describe "#problems" do
    specify { Tailor.problems.should be_a Hash }
    specify { Tailor.problems.should be_empty }
  end

  describe "#check_style" do
    context "single file" do
      before { File.stub(:file?).and_return true }
      after { File.unstub(:file?) }

      it "calls #check_file" do
        Tailor.should_receive(:check_file).once
        Tailor.check_style("a_file.rb")
      end
    end
  end
end
