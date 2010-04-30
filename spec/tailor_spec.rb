require File.dirname(__FILE__) + '/spec_helper.rb'

describe Kernel do
  def self.get_requires
    Dir.chdir '../lib'
    filenames = Dir.glob 'Tailor/*.rb'
    requires = filenames.each do |fn|
      fn.chomp!(File.extname(fn))
    end
    return requires
  end

  # Try to require each of the files in Tailor
  get_requires.each do |r|
    it "should require #{r}" do
      # A require returns true if it was required, false if it had already been
      #   required, and nil if it couldn't require.
      Kernel.require(r.to_s).should_not be_nil
    end
  end
end

describe Tailor do
  it "should have a VERSION constant" do
    Tailor.const_defined?('VERSION').should == true
  end

  it "should return a list of methods with question marks" do
    list = Tailor.question_mark_words
    list.each do |word|
      word.should =~ /\w\?$/
    end
  end
end