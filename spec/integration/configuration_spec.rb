require_relative '../spec_helper'
require 'tailor/configuration'

describe "Config File" do
  before do
    FakeFS.deactivate!
  end

  context ".tailor does not exist" do
    let!(:config) do
      config = Tailor::Configuration.new
      config.load!

      config
    end

    it "sets formatters to 'text'" do
      config.formatters.should == %w(text)
    end

    it "sets file_sets[:default].style to the default style" do
      config.file_sets[:default].style.should_not be_nil
      config.file_sets[:default].style.should == Tailor::Configuration::Style.new.to_hash
    end

    it "sets file_sets[:default].file_list to the files in lib/**/*.rb" do
      config.file_sets[:default].file_list.all? do |path|
        path =~ /tailor\/lib/
      end.should be_true
    end
  end
end
