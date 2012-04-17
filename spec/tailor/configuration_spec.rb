require_relative '../spec_helper'
require 'tailor/configuration'

describe Tailor::Configuration do
  before { Tailor::Logger.stub(:log) }

  subject do
    Tailor::Configuration.new('.')
  end

  describe "#formatters" do
    context "param is nil" do
      it "returns the pre-exisiting @formatters" do
        subject.instance_variable_set(:@formatters, [:blah])
        subject.formatters.should == [:blah]
      end
    end

    context "param is some value" do
      it "sets @formatters to that value" do
        subject.formatters "blah"
        subject.instance_variable_get(:@formatters).should == ["blah"]
      end
    end
  end

  describe "#file_set" do
    before do
      subject.instance_variable_set(:@file_sets, {})
    end

    it "adds the set of stuff to @file_sets" do
      subject.file_set('some_files', :bobo) do |style|
        style.trailing_newlines 2
      end

      subject.instance_variable_get(:@file_sets).should == {
        bobo: {
          file_list: [],
          style: {
            allow_camel_case_methods: [false, { level: :error }],
            allow_hard_tabs: [false, { level: :error }],
            allow_screaming_snake_case_classes: [false, { level: :error }],
            allow_trailing_line_spaces: [false, { level: :error }],
            allow_invalid_ruby: [false, { level: :warn }],
            indentation_spaces: [2, { level: :error }],
            max_code_lines_in_class: [300, { level: :error }],
            max_code_lines_in_method: [30, { level: :error }],
            max_line_length: [80, { level: :error }],
            spaces_after_comma: [1, { level: :error }],
            spaces_after_lbrace: [1, { level: :error }],
            spaces_after_lbracket: [0, { level: :error }],
            spaces_after_lparen: [0, { level: :error }],
            spaces_before_comma: [0, { level: :error }],
            spaces_before_lbrace: [1, { level: :error }],
            spaces_before_rbrace: [1, { level: :error }],
            spaces_before_rbracket: [0, { level: :error }],
            spaces_before_rparen: [0, { level: :error }],
            spaces_in_empty_braces: [0, { level: :error }],
            trailing_newlines: [2, { level: :error }]
          }
        }
      }
    end

    context "first param is nil" do
      it "uses :default as the label" do
        subject.file_set
        subject.instance_variable_get(:@file_sets).should include(:default)
      end
    end
  end

  describe "#confg_file" do
    context "@config_file is already set" do
      it "returns @config_file" do
        subject.instance_variable_set(:@config_file, 'pants')
        subject.config_file
        subject.instance_variable_get(:@config_file).should == 'pants'
      end
    end

    context "@config_file is nil" do
      context "DEFAULT_PROJECT_CONFIG exists" do
        before do
          File.should_receive(:exists?).with(/\.tailor/).and_return true
        end

        it "returns Dir.pwd + './tailor'" do
          subject.config_file
        end
      end

      context "DEFAULT_PROJECT_CONFIG does not exist" do
        before do
          File.should_receive(:exists?).with(/\.tailor/).and_return false
          File.should_receive(:exists?).with(/\.tailorrc/).and_return true
        end

        it "returns DEFAULT_RC_FILE" do
          subject.config_file
          subject.instance_variable_get(:@config_file).should ==
            Tailor::Configuration::DEFAULT_RC_FILE
        end
      end
    end
  end

  describe "#file_list" do
    before do
      FileUtils.mkdir_p 'one/two'
      File.new('one/two/three.rb', 'w') { |f| f.write "stuff" }
    end

    context "glob is an Array" do
      context "the Array has files" do
        it "returns all files in the glob" do
          results = subject.file_list(['one/two/three.rb'])
          results.last.should match /one\/two\/three.rb/
        end
      end

      context "the Array has a directory" do
        context "the directory has files" do
          it "returns all files in the directory" do
            results = subject.file_list(['.'])
            results.last.should match /one\/two\/three.rb/
          end
        end

        context "the directory is empty" do
          before do
            FileUtils.mkdir 'empty'
            FileUtils.rm_rf 'one'
          end

          it "returns an empty Array" do
            results = subject.file_list(['.'])
            results.should == []
          end
        end
      end
    end

    context "glob is a glob" do
      it "returns all files in the glob" do
        results = subject.file_list('one/**/*.rb')
        results.last.should match /one\/two\/three.rb/
      end
    end

    context "glob is a directory" do
      it "returns all files in the glob" do
        results = subject.file_list('one')
        results.last.should match /one\/two\/three.rb/
      end
    end

    context "glob is a file" do
      it "returns all files in the glob" do
        subject.file_list('one/two/three.rb').last.
          should match /one\/two\/three.rb/
      end
    end
  end
end
