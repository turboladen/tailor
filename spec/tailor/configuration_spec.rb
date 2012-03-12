require_relative '../spec_helper'
require 'tailor/configuration'

describe Tailor::Configuration do
  describe "#load_from_file" do
    let!(:config_file_contents) do
      <<-CONFIG
---
:style:
  :indentation:
    :spaces: 2
    :allow_hard_tabs: false
    :continuation_spaces: 2
  :vertical_whitespace:
    :trailing_newlines: 1
:format:
  text
      CONFIG
    end

    let!(:tailorrc_path) { File.expand_path('~/.tailorrc') }

    context "~/.tailorrc exists" do
      before do
        FileUtils.mkdir_p ENV['HOME']
        File.open(tailorrc_path, 'w+') { |f| f.write config_file_contents }
      end

      it "loads that file" do
        YAML.should_receive(:load_file).with(tailorrc_path).and_return(
          YAML.load(config_file_contents)
        )
        subject.load_from_file
      end

      it "sets @style to the the :style section of the config file" do
        YAML.stub(:load_file).with(tailorrc_path).and_return(
          YAML.load(config_file_contents)
        )
        subject.load_from_file
        subject.instance_variable_get(:@style).should == {
          indentation: {
            spaces: 2,
            allow_hard_tabs: false,
            continuation_spaces: 2
          },
          vertical_whitespace: {
            trailing_newlines: 1
          }
        }
      end

      it "sets @formatters to the :format section of the config file" do
        YAML.stub(:load_file).with(tailorrc_path).and_return(
          YAML.load(config_file_contents)
        )
        subject.load_from_file

        subject.instance_variable_get(:@formatters).should == "text"
      end
    end

    context "~/.tailorrc does not exist" do
      let(:default_config_path) do
        File.expand_path(File.dirname(__FILE__) + '/../../tailor_config.yaml.erb')
      end

      before { FakeFS.deactivate! }
      after { FakeFS.activate! }

      it "does not try loading that file" do
        YAML.should_not_receive(:load_file).with(tailorrc_path)
        subject.load_from_file
      end

      it "loads the ERB template file as the config" do
        fake_file = double "File"
        erb = double "ERB", result: "---"
        config = double "config", :[] => true
        File.should_receive(:read).with(default_config_path).and_return fake_file
        ERB.should_receive(:new).and_return(erb)
        YAML.should_receive(:load).and_return(config)
        subject.load_from_file
      end
    end
  end
end
