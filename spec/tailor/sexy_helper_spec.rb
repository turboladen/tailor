require_relative '../spec_helper'
require 'tailor/sexy_helper'

describe Tailor::SexyHelper do
  subject { Tailor::SexyHelper }

  describe "#sexp_cleanup" do
    it "removes the initial :program element" do
      source = %Q{
require 'something'

puts "pants"
      }
      sexp = Ripper.sexp(source)
      sexp.first.should == :program
      sexy_sexp = subject.sexp_cleanup(sexp)
      sexy_sexp.first.should_not == :program
    end
  end
end
