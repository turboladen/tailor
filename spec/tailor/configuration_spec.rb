require_relative '../spec_helper'
require 'tailor/configuration'

describe Tailor::Configuration do
  subject do
    Tailor::Configuration.new('.')
  end

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
        YAML.should_receive(:load_file).with(tailorrc_path).at_least(:once).
          and_return(YAML.load(config_file_contents))
        subject.load_from_file(tailorrc_path)
      end

      it "sets @style to the the :style section of the config file" do
        YAML.should_receive(:load_file).with(tailorrc_path).at_least(:once).
          and_return(YAML.load(config_file_contents))
        subject.load_from_file(tailorrc_path)
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
        subject.load_from_file(tailorrc_path)

        subject.instance_variable_get(:@formatters).should == "text"
      end
    end

    context "~/.tailorrc does not exist" do
      it "does not try loading that file" do
        YAML.should_not_receive(:load_file).with(tailorrc_path)
        subject.load_from_file('.')
      end

      it "does not alter @style" do
        style = double "@style"
        subject.instance_variable_set(:@style, style)
        expect { subject.load_from_file('.') }.to_not change{subject.style}
      end

      it "does not alter @formatters" do
        formatters = double "@formatters"
        subject.instance_variable_set(:@formatters, formatters)
        expect { subject.load_from_file('.') }.to_not change{subject.formatters}
      end
    end
  end
end
