require_relative '../spec_helper'
require 'tailor/configuration'

describe Tailor::Configuration do
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
      subject.file_set(:bobo) do
        trailing_newlines 2
      end

      subject.instance_variable_get(:@file_sets).should == {
        bobo: {
          file_list: [],
          style: {
            :allow_camel_case_methods=>false,
            :allow_hard_tabs=>false,
            :allow_screaming_snake_case_classes=>false,
            :allow_trailing_line_spaces=>false,
            :indentation_spaces=>2,
            :max_code_lines_in_class=>300,
            :max_code_lines_in_method=>30,
            :max_line_length=>80,
            :spaces_after_comma=>1,
            :spaces_before_comma=>0,
            :spaces_before_lbrace=>1,
            :spaces_after_lbrace=>1,
            :spaces_before_rbrace=>1,
            :spaces_in_empty_braces=>0,
            :spaces_after_lbracket=>0,
            :spaces_before_rbracket=>0,
            :spaces_after_lparen=>0,
            :spaces_before_rparen=>0,
            :trailing_newlines=>2
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
      it "returns DEFAULT_RC_FILE" do
        subject.config_file
        subject.instance_variable_get(:@config_file).should ==
          Tailor::Configuration::DEFAULT_RC_FILE
      end
    end
  end
  
  describe "#file_list" do
    before do
      FileUtils.mkdir_p 'one/two'
      File.new('one/two/three.rb', 'w') { |f| f.write "stuff" }
    end

    context "glob is an Array" do
      it "returns all files in the glob" do
        results = subject.file_list(['one/two/three.rb'])
        results.last.should match /one\/two\/three.rb/
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
        subject.file_list('one/two/three.rb').last.should match /one\/two\/three.rb/
      end
    end
  end
end
