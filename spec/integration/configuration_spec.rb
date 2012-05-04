require_relative '../spec_helper'
require 'tailor/configuration'

describe "Config File" do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.deactivate!
  end

  let(:config) do
    config = Tailor::Configuration.new
    config.load!

    config
  end

  context ".tailor does not exist" do
    before do
      Tailor::Configuration.any_instance.stub(:config_file).and_return false
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

  context ".tailor defines the default file set" do
    context "and another file set" do
      let(:config_file) do
        <<-CONFIG
Tailor.config do |config|
  config.file_set 'lib/**/*.rb'

  config.file_set 'features/**/*.rb', :features do |style|
    style.max_line_length 90, level: :warn
  end
end
        CONFIG
      end

      before do
        File.should_receive(:read).and_return config_file
      end

      it "creates the default file set" do
        config.file_sets[:default].style.should == Tailor::Configuration::Style.new.to_hash
        config.file_sets[:default].file_list.all? do |path|
          path =~ /tailor\/lib/
        end.should be_true
      end

      it "creates the :features file set" do
        style = Tailor::Configuration::Style.new
        style.max_line_length(90, level: :warn)
        config.file_sets[:features].style.should == style.to_hash
        config.file_sets[:features].file_list.all? do |path|
          path =~ /features/
        end.should be_true
      end
    end
  end

  context ".tailor defines NO default file set" do
    let(:config_file) do
      <<-CONFIG
Tailor.config do |config|
  config.file_set 'features/**/*.rb', :features do |style|
    style.max_line_length 90, level: :warn
  end
end
      CONFIG
    end

    before do
      File.should_receive(:read).and_return config_file
    end

    it "does not create a :default file set" do
      config.file_sets.should_not include :default
    end

    it "creates the non-default file set" do
      config.file_sets.should include :features
    end
  end
end
