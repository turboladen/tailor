require File.dirname(__FILE__) + '/spec_helper.rb'

describe Kernel do
  def self.get_requires
    Dir.chdir '../lib'
    filenames = Dir.glob 'RubyStyleChecker/*.rb'
    requires = filenames.each do |fn|
      fn.chomp!(File.extname(fn))
    end
    return requires
  end

  # Try to require each of the files in RubyStyleChecker
  get_requires.each do |r|
    it "should require #{r}" do
      # A require returns true if it was required, false if it had already been
      #   required, and nil if it couldn't require.
      Kernel.require(r.to_s).should_not be_nil
    end
  end
end

describe RubyStyleChecker do
  it "should have a VERSION constant" do
    RubyStyleChecker.const_defined?('VERSION').should == true
  end
end