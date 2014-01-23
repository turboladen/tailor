require 'spec_helper'
require 'tailor/configuration/style'


describe Tailor::Configuration::Style do
  describe '.define_property' do
    it 'defines an instance method that takes 2 params' do
      Tailor::Configuration::Style.define_property(:test_method)
      subject.test_method(1, 2)
    end

    it 'allows access to the values via #to_hash' do
      Tailor::Configuration::Style.define_property(:test_method)
      subject.test_method(1, level: :pants)
      subject.to_hash.should include test_method: [1, { level: :pants }]
    end
  end

  describe '#initialize' do
    describe 'sets up default values' do
      describe 'allow_camel_case_methods' do
        specify do
          subject.instance_variable_get(:@allow_camel_case_methods).should == [
            false, { level: :error }]
        end
      end

      describe 'allow_hard_tabs' do
        specify do
          subject.instance_variable_get(:@allow_hard_tabs).should == [
            false, { level: :error }]
        end
      end

      describe 'allow_screaming_snake_case_classes' do
        specify do
          subject.instance_variable_get(:@allow_screaming_snake_case_classes).
            should == [false, { level: :error }]
        end
      end

      describe 'allow_trailing_line_spaces' do
        specify do
          subject.instance_variable_get(:@allow_trailing_line_spaces).
            should == [false, { level: :error }]
        end
      end

      describe 'indentation_spaces' do
        specify do
          subject.instance_variable_get(:@indentation_spaces).should == [
            2, { level: :error }]
        end
      end

      describe 'max_code_lines_in_class' do
        specify do
          subject.instance_variable_get(:@max_code_lines_in_class).should == [
            300, { level: :error }]
        end
      end

      describe 'max_code_lines_in_method' do
        specify do
          subject.instance_variable_get(:@max_code_lines_in_method).should == [
            30, { level: :error }]
        end
      end

      describe 'max_line_length' do
        specify do
          subject.instance_variable_get(:@max_line_length).should == [
            80, { level: :error }]
        end
      end

      describe 'spaces_after_comma' do
        specify do
          subject.instance_variable_get(:@spaces_after_comma).should == [
            1, { level: :error }]
        end
      end

      describe 'spaces_after_lbrace' do
        specify do
          subject.instance_variable_get(:@spaces_after_lbrace).should == [
            1, { level: :error }]
        end
      end

      describe 'spaces_after_lbracket' do
        specify do
          subject.instance_variable_get(:@spaces_after_lbracket).should == [
            0, { level: :error }]
        end
      end

      describe 'spaces_after_lparen' do
        specify do
          subject.instance_variable_get(:@spaces_after_lparen).should == [
            0, { level: :error }]
        end
      end

      describe 'spaces_before_comma' do
        specify do
          subject.instance_variable_get(:@spaces_before_comma).should == [
            0, { level: :error }]
        end
      end

      describe 'spaces_before_lbrace' do
        specify do
          subject.instance_variable_get(:@spaces_before_lbrace).should == [
            1, { level: :error }]
        end
      end

      describe 'spaces_before_rbrace' do
        specify do
          subject.instance_variable_get(:@spaces_before_rbrace).should == [
            1, { level: :error }]
        end
      end

      describe 'spaces_before_rbracket' do
        specify do
          subject.instance_variable_get(:@spaces_before_rbracket).should == [
            0, { level: :error }]
        end
      end

      describe 'spaces_before_rparen' do
        specify do
          subject.instance_variable_get(:@spaces_before_rparen).should == [
            0, { level: :error }]
        end
      end

      describe 'spaces_in_empty_braces' do
        specify do
          subject.instance_variable_get(:@spaces_in_empty_braces).should == [
            0, { level: :error }]
        end
      end

      describe 'trailing_newlines' do
        specify do
          subject.instance_variable_get(:@trailing_newlines).should == [
            1, { level: :error }]
        end
      end
    end
  end

  describe '#to_hash' do
    let(:default_values) do
      {
        :allow_camel_case_methods => [false, { :level => :error }],
        :allow_conditional_parentheses => [false, { :level => :warn }],
        :allow_hard_tabs => [false, { :level => :error }],
        :allow_screaming_snake_case_classes => [false, { :level => :error }],
        :allow_trailing_line_spaces => [false, { :level => :error }],
        :allow_invalid_ruby => [false, { :level => :warn }],
        :indentation_spaces => [2, { :level => :error }],
        :max_code_lines_in_class => [300, { :level => :error }],
        :max_code_lines_in_method => [30, { :level => :error }],
        :max_line_length => [80, { :level => :error }],
        :spaces_after_comma => [1, { :level => :error }],
        :spaces_after_conditional => [1, { :level=>:error }],
        :spaces_after_lbrace => [1, { :level => :error }],
        :spaces_after_lbracket => [0, { :level => :error }],
        :spaces_after_lparen => [0, { :level => :error }],
        :spaces_before_comma => [0, { :level => :error }],
        :spaces_before_lbrace => [1, { :level => :error }],
        :spaces_before_rbrace => [1, { :level => :error }],
        :spaces_before_rbracket => [0, { :level => :error }],
        :spaces_before_rparen => [0, { :level => :error }],
        :spaces_in_empty_braces => [0, { :level => :error }],
        :trailing_newlines => [1, { :level => :error }]
      }
    end

    it 'returns a Hash of all of the attributes and values' do
      subject.to_hash.should == default_values
    end

    context 'with a user-added property' do
      before do
        Tailor::Configuration::Style.define_property(:long_pants)
        subject.long_pants(1, level: :warn)
      end

      it 'includes the new property as part of the Hash' do
        subject.to_hash.should include long_pants: [1, { level: :warn }]
      end
    end
  end
end
